# Communication

- Be concise and use plain language. State material uncertainty and distinguish evidence from judgment. Do not use em dashes.
- Use Conventional Commits for commit messages and PR titles.
- Keep PR descriptions short: scope, implementation summary, and verification.
- Keep comments and updates across tools and documents high-signal: only material findings, blockers, decisions, or outcomes. Skip routine narration, repetition, and empty acknowledgments. Batch related updates and prefer updating existing content over adding status comments. If nothing materially changed, say nothing.

# Coding

- Follow established workflows; fix blockers at their source rather than bypassing them.
- Default to the smallest working change that meets the request. Reuse what exists; avoid new abstractions, dependencies, configuration options, and fallback paths unless necessary. Leave adjacent problems alone and stop when the requested outcome is verified.
- When summarizing completed work, state whether the requested outcome works, what was verified, and what remains. Distinguish implemented, deployed, and verified.
- Document only non-obvious, durable usage and operational requirements. Keep ticket references, implementation history, and one-off verification or migration details in PRs/issues, not code or repository docs.

# Security and privacy

- Never expose secrets or unnecessary personal or confidential data in prompts, repositories, docs, or tool output.
- Check repositories for secrets before pushing or publishing.
- Never ask for passwords or 2FA codes, let the user authenticate.

# Browser use

- To "open" a URL, use `/usr/bin/open` on macOS or `xdg-open` on Linux, not browser automation.
- Use `chrome-isolated` for public pages and unauthenticated testing, never login or SSO.
- Use `chrome-user-profile` only for authorized authenticated access. Avoid exposing unrelated sensitive tabs.
