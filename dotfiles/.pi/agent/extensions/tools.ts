import {
	DynamicBorder,
	getMarkdownTheme,
	type ExtensionAPI,
	type ExtensionCommandContext,
	type ExtensionContext,
	type ToolInfo,
} from "@earendil-works/pi-coding-agent";
import { Markdown, matchesKey } from "@earendil-works/pi-tui";

type JsonSchema = {
	type?: string | string[];
	description?: string;
	properties?: Record<string, JsonSchema>;
	required?: string[];
	items?: JsonSchema;
	enum?: unknown[];
	const?: unknown;
	default?: unknown;
	anyOf?: JsonSchema[];
	oneOf?: JsonSchema[];
	allOf?: JsonSchema[];
	$ref?: string;
	additionalProperties?: boolean | JsonSchema;
	[key: string]: unknown;
};

const MAX_INSTRUCTION_CHARS = 600;
const MAX_ARGS_CHARS = 120;
const STATE_TYPE = "tools-config";

type ToolsState = {
	enabledTools: string[];
};

function clean(text: string): string {
	return text.replace(/\s+/g, " ").trim();
}

function escapeCell(text: string): string {
	return clean(text).replace(/\|/g, "\\|");
}

function truncate(text: string, max: number): string {
	const normalized = clean(text);
	return normalized.length <= max ? normalized : `${normalized.slice(0, Math.max(0, max - 1)).trimEnd()}…`;
}

function formatValue(value: unknown): string {
	if (typeof value === "string") {
		return JSON.stringify(value);
	}
	return String(value);
}

function schemaType(schema: JsonSchema | undefined): string {
	if (!schema) {
		return "unknown";
	}
	if (schema.$ref) {
		return schema.$ref.split("/").at(-1) ?? schema.$ref;
	}
	if (schema.const !== undefined) {
		return formatValue(schema.const);
	}
	if (schema.enum) {
		return schema.enum.map(formatValue).join(" | ");
	}
	if (schema.anyOf) {
		return schema.anyOf.map(schemaType).join(" | ");
	}
	if (schema.oneOf) {
		return schema.oneOf.map(schemaType).join(" | ");
	}
	if (schema.allOf) {
		return schema.allOf.map(schemaType).join(" & ");
	}
	if (Array.isArray(schema.type)) {
		return schema.type.join(" | ");
	}
	if (schema.type === "array") {
		return `${schemaType(schema.items)}[]`;
	}
	if (schema.type) {
		return schema.type;
	}
	if (schema.properties) {
		return "object";
	}
	return "unknown";
}

function describeParameter(name: string, schema: JsonSchema, required: Set<string>, includeDescription: boolean): string {
	const optional = required.has(name) ? "" : "?";
	const defaultText = schema.default === undefined ? "" : ` = ${formatValue(schema.default)}`;
	const description = includeDescription && schema.description ? ` -- ${clean(schema.description)}` : "";
	return `${name}${optional}: ${schemaType(schema)}${defaultText}${description}`;
}

function summarizeParameters(parameters: unknown, includeDescriptions = false): string {
	const schema = parameters as JsonSchema | undefined;
	if (!schema?.properties || Object.keys(schema.properties).length === 0) {
		return "none";
	}

	const required = new Set(schema.required ?? []);
	return Object.entries(schema.properties)
		.map(([name, paramSchema]) => describeParameter(name, paramSchema, required, includeDescriptions))
		.join("; ");
}

function toolInstructions(tool: ToolInfo): string {
	const guidelines = tool.promptGuidelines?.length ? ` Guidelines: ${tool.promptGuidelines.join(" ")}` : "";
	return clean(`${tool.description}${guidelines}`);
}

function sourceLabel(tool: ToolInfo): string {
	const source = tool.sourceInfo.source || tool.sourceInfo.scope;
	return `${source}/${tool.sourceInfo.origin}`;
}

function sortTools(tools: ToolInfo[], activeToolNames: string[]): ToolInfo[] {
	const active = new Set(activeToolNames);
	return [...tools].sort((a, b) => {
		const activeDelta = Number(active.has(b.name)) - Number(active.has(a.name));
		return activeDelta || a.name.localeCompare(b.name);
	});
}

function formatToolTable(tools: ToolInfo[], activeToolNames: string[]): string {
	const active = new Set(activeToolNames);
	const lines = [
		`# Tools (${active.size}/${tools.length} active)`,
		"",
		"| Active | Tool | Args | Instructions | Source |",
		"|---|---|---|---|---|",
	];

	for (const tool of sortTools(tools, activeToolNames)) {
		lines.push(
			`| ${active.has(tool.name) ? "yes" : "no"} | ${escapeCell(tool.name)} | ${escapeCell(
				truncate(summarizeParameters(tool.parameters), MAX_ARGS_CHARS),
			)} | ${escapeCell(truncate(toolInstructions(tool), MAX_INSTRUCTION_CHARS))} | ${escapeCell(sourceLabel(tool))} |`,
		);
	}

	lines.push(
		"",
		"Actions: `/tools enable <name...>`, `/tools disable <name...>`, `/tools toggle <name...>`, `/tools reset`.",
		"Details: run `/tools <tool-name>` for full parameter descriptions, prompt guidelines, source path, and raw schema.",
	);
	return lines.join("\n");
}

function formatToolDetails(tool: ToolInfo, activeToolNames: string[]): string {
	const active = new Set(activeToolNames);
	const lines = [
		`# ${tool.name}`,
		"",
		`Active: ${active.has(tool.name) ? "yes" : "no"}`,
		`Source: ${sourceLabel(tool)}`,
		`Path: ${tool.sourceInfo.path}`,
		"",
		"## Instructions",
		tool.description,
	];

	if (tool.promptGuidelines?.length) {
		lines.push("", "## Prompt guidelines", ...tool.promptGuidelines.map((guideline) => `- ${guideline}`));
	}

	lines.push("", "## Parameters", summarizeParameters(tool.parameters, true), "", "## Raw schema", "```json");
	lines.push(JSON.stringify(tool.parameters, null, 2));
	lines.push("```");

	return lines.join("\n");
}

async function showText(ctx: ExtensionCommandContext, title: string, text: string): Promise<void> {
	if (!ctx.hasUI) {
		ctx.ui.notify(text, "info");
		return;
	}

	await ctx.ui.custom<void>((_tui, theme, _kb, done) => {
		const markdown = new Markdown(text, 1, 0, getMarkdownTheme());
		const border = new DynamicBorder((s: string) => theme.fg("accent", s));

		return {
			render: (width: number) => [
				...border.render(width),
				theme.fg("accent", theme.bold(title)),
				...markdown.render(width),
				theme.fg("dim", "enter/esc/q close"),
				...border.render(width),
			],
			invalidate: () => markdown.invalidate(),
			handleInput: (data: string) => {
				if (matchesKey(data, "escape") || matchesKey(data, "enter") || data === "q") {
					done(undefined);
				}
			},
		};
	});
}

function restoreFromBranch(pi: ExtensionAPI, ctx: ExtensionContext): void {
	const tools = pi.getAllTools();
	const allToolNames = new Set(tools.map((tool) => tool.name));
	let savedTools: string[] | undefined;

	for (const entry of ctx.sessionManager.getBranch()) {
		if (entry.type === "custom" && entry.customType === STATE_TYPE) {
			const state = entry.data as ToolsState | undefined;
			if (state?.enabledTools) {
				savedTools = state.enabledTools;
			}
		}
	}

	if (savedTools) {
		pi.setActiveTools(savedTools.filter((name) => allToolNames.has(name)));
	}
}

function persistActiveTools(pi: ExtensionAPI): void {
	pi.appendEntry<ToolsState>(STATE_TYPE, { enabledTools: pi.getActiveTools() });
}

function resolveToolNames(tools: ToolInfo[], names: string[]): { valid: string[]; invalid: string[] } {
	const allToolNames = new Set(tools.map((tool) => tool.name));
	return {
		valid: names.filter((name) => allToolNames.has(name)),
		invalid: names.filter((name) => !allToolNames.has(name)),
	};
}

function applyToolAction(pi: ExtensionAPI, tools: ToolInfo[], action: string, names: string[]): string {
	const allToolNames = tools.map((tool) => tool.name);
	const active = new Set(pi.getActiveTools());

	if (action === "reset") {
		pi.setActiveTools(allToolNames);
		persistActiveTools(pi);
		return `Enabled all ${allToolNames.length} tools.`;
	}

	const { valid, invalid } = resolveToolNames(tools, names);
	if (invalid.length) {
		return `Unknown tool${invalid.length === 1 ? "" : "s"}: ${invalid.join(", ")}`;
	}
	if (valid.length === 0) {
		return `Usage: /tools ${action} <tool-name...>`;
	}

	for (const name of valid) {
		if (action === "enable") {
			active.add(name);
		} else if (action === "disable") {
			active.delete(name);
		} else if (action === "toggle") {
			if (active.has(name)) active.delete(name);
			else active.add(name);
		}
	}

	pi.setActiveTools(allToolNames.filter((name) => active.has(name)));
	persistActiveTools(pi);
	return `${action === "toggle" ? "Toggled" : action === "enable" ? "Enabled" : "Disabled"}: ${valid.join(", ")}`;
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("tools", {
		description: "Show, enable, disable, and inspect tools",
		handler: async (args, ctx) => {
			const tools = pi.getAllTools();
			const parts = args.trim().split(/\s+/).filter(Boolean);
			const query = parts.join(" ");

			if (tools.length === 0) {
				ctx.ui.notify("No tools are configured.", "info");
				return;
			}

			const action = parts[0];
			if (["enable", "disable", "toggle", "reset"].includes(action)) {
				const message = applyToolAction(pi, tools, action, parts.slice(1));
				ctx.ui.notify(message, message.startsWith("Unknown") || message.startsWith("Usage") ? "warning" : "info");
				return;
			}

			const activeToolNames = pi.getActiveTools();
			if (query) {
				const tool = tools.find((candidate) => candidate.name === query);
				if (!tool) {
					const matches = tools.filter((candidate) => candidate.name.includes(query)).map((candidate) => candidate.name);
					ctx.ui.notify(
						matches.length
							? `Unknown tool "${query}". Did you mean: ${matches.join(", ")}?`
							: `Unknown tool "${query}".`,
						"error",
					);
					return;
				}

				await showText(ctx, `Tool: ${tool.name}`, formatToolDetails(tool, activeToolNames));
				return;
			}

			await showText(ctx, "Tools", formatToolTable(tools, activeToolNames));
		},
	});

	pi.on("session_start", async (_event, ctx) => {
		restoreFromBranch(pi, ctx);
	});

	pi.on("session_tree", async (_event, ctx) => {
		restoreFromBranch(pi, ctx);
	});
}
