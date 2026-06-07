import type { AgentMessage } from "@earendil-works/pi-agent-core";
import { DynamicBorder, type ExtensionAPI, type ExtensionContext, type SessionEntry, type ToolInfo } from "@earendil-works/pi-coding-agent";
import { matchesKey, truncateToWidth } from "@earendil-works/pi-tui";

const ESTIMATED_IMAGE_CHARS = 4800;
const STATUS_KEY = "context-estimate";
const COMPACTION_SUMMARY_PREFIX = `The conversation history before this point was compacted into the following summary:\n\n<summary>\n`;
const COMPACTION_SUMMARY_SUFFIX = `\n</summary>`;
const BRANCH_SUMMARY_PREFIX = `The following is a summary of a branch that this conversation came back from:\n\n<summary>\n`;
const BRANCH_SUMMARY_SUFFIX = `</summary>`;

type ToolInventory = {
	activeToolNames: string[];
	allTools: ToolInfo[];
};

type Breakdown = {
	systemPromptBase: number;
	projectInstructions: number;
	skills: number;
	toolSchemas: number;
	userMessages: number;
	assistantText: number;
	assistantThinking: number;
	toolCalls: number;
	toolResults: number;
	bashExecutions: number;
	summaries: number;
	customMessages: number;
	other: number;
};

type BreakdownKey = keyof Breakdown;

type BreakdownRow = {
	key: BreakdownKey;
	label: string;
	group: "System" | "Conversation";
};

const BREAKDOWN_ROWS: BreakdownRow[] = [
	{ key: "systemPromptBase", label: "Prompt base", group: "System" },
	{ key: "projectInstructions", label: "Project instructions", group: "System" },
	{ key: "skills", label: "Skills list", group: "System" },
	{ key: "toolSchemas", label: "Tool schemas", group: "System" },
	{ key: "userMessages", label: "User messages", group: "Conversation" },
	{ key: "assistantText", label: "Assistant text", group: "Conversation" },
	{ key: "assistantThinking", label: "Assistant thinking", group: "Conversation" },
	{ key: "toolCalls", label: "Tool calls", group: "Conversation" },
	{ key: "toolResults", label: "Tool results", group: "Conversation" },
	{ key: "bashExecutions", label: "Bash executions", group: "Conversation" },
	{ key: "summaries", label: "Summaries", group: "Conversation" },
	{ key: "customMessages", label: "Custom messages", group: "Conversation" },
	{ key: "other", label: "Other", group: "Conversation" },
];

function formatTokens(tokens: number): string {
	return new Intl.NumberFormat("en-US").format(tokens);
}

function formatPercent(percent: number): string {
	return `${percent.toFixed(1)}%`;
}

function estimateChars(chars: number): number {
	return Math.ceil(Math.max(chars, 0) / 4);
}

function estimateText(text: string): number {
	return estimateChars(text.length);
}

function estimateJson(value: unknown): number {
	try {
		return estimateText(JSON.stringify(value) ?? "");
	} catch {
		return 0;
	}
}

function contentChars(content: unknown): number {
	if (typeof content === "string") {
		return content.length;
	}
	if (!Array.isArray(content)) {
		return 0;
	}

	let chars = 0;
	for (const block of content) {
		if (!block || typeof block !== "object") {
			continue;
		}
		const typedBlock = block as { type?: string; text?: string };
		if (typedBlock.type === "text" && typeof typedBlock.text === "string") {
			chars += typedBlock.text.length;
		} else if (typedBlock.type === "image") {
			chars += ESTIMATED_IMAGE_CHARS;
		}
	}
	return chars;
}

function estimateContent(content: unknown): number {
	return estimateChars(contentChars(content));
}

function extractSection(text: string, start: string, end: string): string {
	const startIndex = text.indexOf(start);
	if (startIndex < 0) {
		return "";
	}
	const endIndex = text.indexOf(end, startIndex);
	if (endIndex < 0) {
		return text.slice(startIndex);
	}
	return text.slice(startIndex, endIndex + end.length);
}

function getSystemPromptBreakdown(systemPrompt: string): Pick<Breakdown, "systemPromptBase" | "projectInstructions" | "skills"> {
	const projectContext = extractSection(systemPrompt, "<project_context>", "</project_context>");
	const skills = extractSection(systemPrompt, "The following skills provide specialized instructions", "</available_skills>");
	const baseChars = systemPrompt.length - projectContext.length - skills.length;

	return {
		systemPromptBase: estimateChars(baseChars),
		projectInstructions: estimateText(projectContext),
		skills: estimateText(skills),
	};
}

function getActiveToolSchemaTokens(allTools: ToolInfo[], activeToolNames: string[]): number {
	const active = new Set(activeToolNames);
	const toolSchemas = allTools
		.filter((tool) => active.has(tool.name))
		.map((tool) => ({
			name: tool.name,
			description: tool.description,
			parameters: tool.parameters,
		}));

	return estimateJson(toolSchemas);
}

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

function getContextMessages(branch: SessionEntry[]): AgentMessage[] {
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

function addMessageTokens(breakdown: Breakdown, message: AgentMessage): void {
	switch (message.role) {
		case "user": {
			breakdown.userMessages += estimateContent(message.content);
			return;
		}
		case "assistant": {
			for (const block of message.content) {
				if (block.type === "text") {
					breakdown.assistantText += estimateText(block.text);
				} else if (block.type === "thinking") {
					breakdown.assistantThinking += estimateText(block.thinking);
				} else if (block.type === "toolCall") {
					breakdown.toolCalls += estimateText(block.name) + estimateJson(block.arguments);
				}
			}
			return;
		}
		case "toolResult": {
			breakdown.toolResults += estimateContent(message.content);
			return;
		}
		case "bashExecution": {
			if (!message.excludeFromContext) {
				breakdown.bashExecutions += estimateText(message.command) + estimateText(message.output);
			}
			return;
		}
		case "branchSummary": {
			breakdown.summaries += estimateText(BRANCH_SUMMARY_PREFIX + message.summary + BRANCH_SUMMARY_SUFFIX);
			return;
		}
		case "compactionSummary": {
			breakdown.summaries += estimateText(COMPACTION_SUMMARY_PREFIX + message.summary + COMPACTION_SUMMARY_SUFFIX);
			return;
		}
		case "custom": {
			breakdown.customMessages += estimateContent(message.content);
			return;
		}
		default: {
			breakdown.other += estimateJson(message);
		}
	}
}

function sumBreakdown(breakdown: Breakdown): number {
	return Object.values(breakdown).reduce((total, tokens) => total + tokens, 0);
}

function buildBreakdown(ctx: ExtensionContext, allTools: ToolInfo[], activeToolNames: string[]): Breakdown {
	const system = getSystemPromptBreakdown(ctx.getSystemPrompt());
	const breakdown: Breakdown = {
		...system,
		toolSchemas: getActiveToolSchemaTokens(allTools, activeToolNames),
		userMessages: 0,
		assistantText: 0,
		assistantThinking: 0,
		toolCalls: 0,
		toolResults: 0,
		bashExecutions: 0,
		summaries: 0,
		customMessages: 0,
		other: 0,
	};

	for (const message of getContextMessages(ctx.sessionManager.getBranch())) {
		addMessageTokens(breakdown, message);
	}

	return breakdown;
}

function line(label: string, tokens: number): string {
	return `  - ${label}: ${formatTokens(tokens)}`;
}

function formatCompactTokens(tokens: number): string {
	if (tokens >= 1_000_000) {
		const value = tokens / 1_000_000;
		return `${value >= 10 ? value.toFixed(0) : value.toFixed(1)}m`;
	}
	if (tokens >= 1_000) {
		return `${Math.round(tokens / 1_000)}k`;
	}
	return String(Math.max(0, Math.round(tokens)));
}

const SEGMENT_COLORS = [81, 141, 118, 220, 208, 197, 75, 50, 180, 111, 203, 154];

type SegmentPart = {
	row: BreakdownRow;
	tokens: number;
};

function colorSegment(index: number, text: string): string {
	return `\x1b[38;5;${SEGMENT_COLORS[index % SEGMENT_COLORS.length]}m${text}\x1b[39m`;
}

function segmentMarker(index: number): string {
	return colorSegment(index, "██");
}

function allocateSegmentWidths(parts: SegmentPart[], total: number, width: number): number[] {
	if (parts.length === 0 || total <= 0 || width <= 0) {
		return [];
	}

	const widths = parts.map(() => (width >= parts.length ? 1 : 0));
	let remaining = Math.max(0, width - widths.reduce((sum, value) => sum + value, 0));
	const fractional = parts.map((part, index) => {
		const exact = (part.tokens / total) * remaining;
		const whole = Math.floor(exact);
		widths[index] += whole;
		return { index, fraction: exact - whole };
	});

	remaining = width - widths.reduce((sum, value) => sum + value, 0);
	fractional.sort((a, b) => b.fraction - a.fraction);
	for (let i = 0; i < remaining; i++) {
		widths[fractional[i % fractional.length].index]++;
	}

	return widths;
}

function renderSegmentedBar(parts: SegmentPart[], total: number, width: number): string {
	const widths = allocateSegmentWidths(parts, total, width);
	return `[${parts.map((_part, index) => colorSegment(index, "█".repeat(widths[index] ?? 0))).join("")}]`;
}

function renderGroupVisualization(
	group: BreakdownRow["group"],
	breakdown: Breakdown,
	activeToolCount: number,
	estimatedTotal: number,
	theme: ExtensionContext["ui"]["theme"],
	width: number,
): string[] {
	const parts = BREAKDOWN_ROWS.filter((row) => row.group === group && breakdown[row.key] > 0).map((row) => ({
		row,
		tokens: breakdown[row.key],
	}));
	const groupTotal = parts.reduce((sum, part) => sum + part.tokens, 0);
	if (groupTotal === 0) {
		return [];
	}

	const lines: string[] = [];
	const groupShare = estimatedTotal > 0 ? (groupTotal / estimatedTotal) * 100 : 0;
	const barWidth = Math.max(16, Math.min(60, width - 28));
	lines.push("");
	lines.push(`${group}: ${formatCompactTokens(groupTotal)} tokens, ${formatPercent(groupShare)} of categorized total`);
	lines.push(`  ${renderSegmentedBar(parts, groupTotal, barWidth)}`);

	for (const [index, part] of parts.entries()) {
		const label = part.row.label === "Tool schemas" ? `Tool schemas (${activeToolCount})` : part.row.label;
		const percent = groupTotal > 0 ? (part.tokens / groupTotal) * 100 : 0;
		lines.push(`  ${segmentMarker(index)} ${label.padEnd(22).slice(0, 22)} ${formatCompactTokens(part.tokens).padStart(5)}  ${formatPercent(percent).padStart(6)}`);
	}

	return lines;
}

function renderVisualization(
	breakdown: Breakdown,
	activeToolCount: number,
	usage: NonNullable<ReturnType<ExtensionContext["getContextUsage"]>>,
	theme: ExtensionContext["ui"]["theme"],
	width: number,
): string[] {
	const estimatedTotal = sumBreakdown(breakdown);
	const shownTotal = usage.tokens ?? estimatedTotal;
	const shownPercent = usage.percent ?? (usage.contextWindow > 0 ? (shownTotal / usage.contextWindow) * 100 : 0);
	const lines: string[] = [];

	lines.push(theme.bold("Context usage"));
	lines.push(
		`${usage.tokens === null ? "Estimated" : "Provider"}: ${formatTokens(shownTotal)} / ${formatTokens(
			usage.contextWindow,
		)} tokens (${formatPercent(shownPercent)})`,
	);
	if (usage.tokens !== null) {
		const delta = usage.tokens - estimatedTotal;
		lines.push(
			`Categorized estimate: ${formatTokens(estimatedTotal)} (${delta >= 0 ? "+" : ""}${formatTokens(
				delta,
			)} vs provider)`,
		);
	} else {
		lines.push(theme.fg("dim", "Provider count is unknown until the next assistant response after compaction/handoff."));
	}
	lines.push("Each group bar is 100%; colors match legend rows.");

	lines.push(...renderGroupVisualization("System", breakdown, activeToolCount, estimatedTotal, theme, width));
	lines.push(...renderGroupVisualization("Conversation", breakdown, activeToolCount, estimatedTotal, theme, width));

	lines.push("");
	lines.push(theme.fg("dim", "enter / esc / q close"));
	return lines.map((line) => truncateToWidth(line, width));
}

async function showBreakdownVisualization(
	ctx: ExtensionContext,
	breakdown: Breakdown,
	activeToolCount: number,
	usage: NonNullable<ReturnType<ExtensionContext["getContextUsage"]>>,
): Promise<void> {
	await ctx.ui.custom<void>((_tui, theme, _keybindings, done) => {
		const border = new DynamicBorder((text: string) => theme.fg("accent", text));

		return {
			render: (width: number) => [
				...border.render(width),
				...renderVisualization(breakdown, activeToolCount, usage, theme, width),
				...border.render(width),
			],
			invalidate: () => border.invalidate(),
			handleInput: (data: string) => {
				if (matchesKey(data, "escape") || matchesKey(data, "enter") || data === "q") {
					done(undefined);
				}
			},
		};
	});
}

export function updateEstimateStatus(ctx: ExtensionContext, tools: ExtensionAPI | ToolInventory): void {
	const usage = ctx.getContextUsage();
	if (!usage) {
		ctx.ui.setStatus(STATUS_KEY, undefined);
		return;
	}

	if (usage.tokens !== null && usage.percent !== null) {
		ctx.ui.setStatus(STATUS_KEY, undefined);
		return;
	}

	const activeToolNames = "getActiveTools" in tools ? tools.getActiveTools() : tools.activeToolNames;
	const allTools = "getAllTools" in tools ? tools.getAllTools() : tools.allTools;
	const estimatedTotal = sumBreakdown(buildBreakdown(ctx, allTools, activeToolNames));
	ctx.ui.setStatus(
		STATUS_KEY,
		ctx.ui.theme.fg("dim", `est ${formatCompactTokens(estimatedTotal)}/${formatCompactTokens(usage.contextWindow)}`),
	);
}

function formatBreakdown(breakdown: Breakdown, activeToolCount: number, actualTokens: number | null): string {
	const estimatedTotal = sumBreakdown(breakdown);
	const parts = [
		"Breakdown (approx, chars/4):",
		"System:",
		line("Prompt base", breakdown.systemPromptBase),
		line("Project instructions", breakdown.projectInstructions),
		line("Skills list", breakdown.skills),
		line(`Tool schemas (${activeToolCount} active)`, breakdown.toolSchemas),
		"Conversation:",
		line("User messages", breakdown.userMessages),
		line("Assistant text", breakdown.assistantText),
		line("Assistant thinking", breakdown.assistantThinking),
		line("Tool calls", breakdown.toolCalls),
		line("Tool results", breakdown.toolResults),
		line("Bash executions", breakdown.bashExecutions),
		line("Summaries", breakdown.summaries),
		line("Custom messages", breakdown.customMessages),
	];

	if (breakdown.other > 0) {
		parts.push(line("Other", breakdown.other));
	}

	parts.push(`Estimated categorized total: ${formatTokens(estimatedTotal)}`);
	if (actualTokens !== null) {
		const delta = actualTokens - estimatedTotal;
		parts.push(`Delta vs provider total: ${delta >= 0 ? "+" : ""}${formatTokens(delta)}`);
	}

	return parts.join("\n");
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => updateEstimateStatus(ctx, pi));
	pi.on("session_compact", (_event, ctx) => updateEstimateStatus(ctx, pi));
	pi.on("session_tree", (_event, ctx) => updateEstimateStatus(ctx, pi));
	pi.on("model_select", (_event, ctx) => updateEstimateStatus(ctx, pi));
	pi.on("agent_end", (_event, ctx) => updateEstimateStatus(ctx, pi));
	pi.on("turn_end", (_event, ctx) => updateEstimateStatus(ctx, pi));

	pi.registerCommand("context-usage", {
		description: "Show current context-window usage with category breakdown",
		handler: async (_args, ctx) => {
			const usage = ctx.getContextUsage();

			if (!usage) {
				ctx.ui.notify("Context usage unavailable: no active model or context window.", "warning");
				return;
			}

			const contextWindow = formatTokens(usage.contextWindow);
			const activeToolNames = pi.getActiveTools();
			const breakdown = buildBreakdown(ctx, pi.getAllTools(), activeToolNames);
			const activeToolCount = activeToolNames.length;

			if (ctx.hasUI && ctx.mode !== "rpc") {
				await showBreakdownVisualization(ctx, breakdown, activeToolCount, usage);
				return;
			}

			const breakdownText = formatBreakdown(breakdown, activeToolCount, usage.tokens);

			if (usage.tokens === null || usage.percent === null) {
				const estimatedTotal = sumBreakdown(breakdown);
				ctx.ui.notify(
					`Context usage unknown / ${contextWindow} tokens. Estimated categorized total: ${formatTokens(estimatedTotal)} (${formatPercent(
						(estimatedTotal / usage.contextWindow) * 100,
					)}). This is expected immediately after compaction until the next assistant response records fresh usage.\n${breakdownText}`,
					"info",
				);
				return;
			}

			ctx.ui.notify(
				`Context usage: ${formatTokens(usage.tokens)} / ${contextWindow} tokens (${formatPercent(usage.percent)}).\n${breakdownText}`,
				"info",
			);
		},
	});
}
