/**
 * /handoff - transfer current context to a fresh, focused session.
 *
 * Usage:
 *   /handoff
 *   /handoff implement the next phase
 *   /handoff review the final diff
 *
 * The command summarizes the current branch, creates a new session, and stores
 * the summary as compacted context without adding a follow-up prompt.
 */

import type { AgentMessage } from "@earendil-works/pi-agent-core";
import { complete, type Message } from "@earendil-works/pi-ai";
import type { ExtensionAPI, SessionEntry } from "@earendil-works/pi-coding-agent";
import { BorderedLoader, convertToLlm, serializeConversation } from "@earendil-works/pi-coding-agent";
import { updateEstimateStatus } from "./context-usage.ts";

const DEFAULT_GOAL = "continue the current task";

const SYSTEM_PROMPT = `You are a context handoff assistant for a coding agent session. Given a conversation history and the user's goal for a fresh session, generate a self-contained handoff prompt that preserves everything needed to continue after clearing context.

Requirements:
- Be concise, but do not omit decisions, constraints, current state, or verification status needed to continue safely.
- Hard limit: about 1,200 words. Compress aggressively when history is large.
- If history contains previous handoff or compaction summaries, merge them into the current state instead of repeating them verbatim.
- Prefer concrete file paths, commands, tickets, URLs, and exact next steps over generic summaries.
- Mention what was read or modified when relevant.
- Clearly separate completed work from in-progress or blocked work.
- Do not include a preamble like "Here is the handoff". Output only the handoff summary for the next session.

Use this format:

## Goal
[What the user is trying to accomplish]

## Constraints & Preferences
- [User requirements, style preferences, safety constraints]

## Progress
### Done
- [x] [Completed work]

### In Progress
- [ ] [Current work]

### Blocked
- [Blockers, or "None"]

## Key Decisions
- **[Decision]**: [Rationale]

## Next Steps
1. [Immediate next action]

## Critical Context
- [Facts the next session needs]

<read-files>
path/to/file1
</read-files>

<modified-files>
path/to/file2
</modified-files>`;

function entryToMessage(entry: SessionEntry): AgentMessage | undefined {
	if (entry.type === "message") {
		return entry.message;
	}
	if (entry.type === "compaction") {
		return {
			role: "compactionSummary",
			summary: entry.summary,
			tokensBefore: entry.tokensBefore,
			timestamp: new Date(entry.timestamp).getTime(),
		};
	}
	if (entry.type === "branch_summary") {
		return {
			role: "branchSummary",
			summary: entry.summary,
			fromId: entry.fromId,
			timestamp: new Date(entry.timestamp).getTime(),
		};
	}
	if (entry.type === "custom_message") {
		return {
			role: "custom",
			customType: entry.customType,
			content: entry.content,
			display: entry.display,
			details: entry.details,
			timestamp: new Date(entry.timestamp).getTime(),
		};
	}
	return undefined;
}

function getHandoffMessages(branch: SessionEntry[]): AgentMessage[] {
	let compactionIndex = -1;
	for (let i = branch.length - 1; i >= 0; i--) {
		if (branch[i].type === "compaction") {
			compactionIndex = i;
			break;
		}
	}

	if (compactionIndex < 0) {
		return branch.map(entryToMessage).filter((message) => message !== undefined);
	}

	const compaction = branch[compactionIndex];
	const firstKeptIndex =
		compaction.type === "compaction" ? branch.findIndex((entry) => entry.id === compaction.firstKeptEntryId) : -1;
	const compactedBranch = [
		compaction,
		...(firstKeptIndex >= 0 ? branch.slice(firstKeptIndex, compactionIndex) : []),
		...branch.slice(compactionIndex + 1),
	];
	return compactedBranch.map(entryToMessage).filter((message) => message !== undefined);
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("handoff", {
		description: "Summarize context into a fresh focused session",
		handler: async (args, ctx) => {
			if (!ctx.hasUI) {
				ctx.ui.notify("handoff requires interactive mode", "error");
				return;
			}

			if (!ctx.model) {
				ctx.ui.notify("No model selected", "error");
				return;
			}

			await ctx.waitForIdle();

			const goal = args.trim() || DEFAULT_GOAL;

			const messages = getHandoffMessages(ctx.sessionManager.getBranch());
			if (messages.length === 0) {
				ctx.ui.notify("No conversation to hand off", "error");
				return;
			}

			const llmMessages = convertToLlm(messages);
			const conversationText = serializeConversation(llmMessages);
			const currentSessionFile = ctx.sessionManager.getSessionFile();
			const tokensBefore = ctx.getContextUsage()?.tokens ?? 0;

			const result = await ctx.ui.custom<string | null>((tui, theme, _kb, done) => {
				const loader = new BorderedLoader(tui, theme, "Generating handoff prompt...");
				loader.onAbort = () => done(null);

				const doGenerate = async () => {
					const auth = await ctx.modelRegistry.getApiKeyAndHeaders(ctx.model!);
					if (!auth.ok || !auth.apiKey) {
						throw new Error(auth.ok ? `No API key for ${ctx.model!.provider}` : auth.error);
					}

					const userMessage: Message = {
						role: "user",
						content: [
							{
								type: "text",
								text: `## Conversation History\n\n${conversationText}\n\n## User's Goal for Fresh Session\n\n${goal}`,
							},
						],
						timestamp: Date.now(),
					};

					const response = await complete(
						ctx.model!,
						{ systemPrompt: SYSTEM_PROMPT, messages: [userMessage] },
						{ apiKey: auth.apiKey, headers: auth.headers, signal: loader.signal },
					);

					if (response.stopReason === "aborted") {
						return null;
					}

					return response.content
						.filter((content): content is { type: "text"; text: string } => content.type === "text")
						.map((content) => content.text)
						.join("\n")
						.trim();
				};

				doGenerate()
					.then(done)
					.catch((error) => {
						console.error("Handoff generation failed:", error);
						done(null);
					});

				return loader;
			});

			if (!result) {
				ctx.ui.notify("Cancelled or failed to generate handoff", "info");
				return;
			}

			const handoffSummary = result;
			// The extension API object is invalidated during session replacement.
			// Snapshot tool metadata before ctx.newSession() so the replacement-session
			// footer estimate can be computed without touching stale extension state.
			const toolInventory = {
				activeToolNames: pi.getActiveTools(),
				allTools: pi.getAllTools(),
			};

			const newSessionResult = await ctx.newSession({
				parentSession: currentSessionFile,
				setup: async (sessionManager) => {
					// Store the handoff as compacted context instead of a large user prompt.
					// This keeps the fresh session bounded and prevents repeated /handoff
					// runs from nesting old handoff prompts into ever-growing context.
					sessionManager.appendCompaction(handoffSummary, "root", tokensBefore, { source: "handoff" }, true);
				},
				withSession: async (replacementCtx) => {
					updateEstimateStatus(replacementCtx, toolInventory);
					replacementCtx.ui.notify("Handoff summary stored in fresh session.", "info");
				},
			});

			if (newSessionResult.cancelled) {
				ctx.ui.notify("New session cancelled", "info");
			}
		},
	});
}
