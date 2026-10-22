# Communication and authorization

- Be concise and use plain language. State material uncertainty and distinguish evidence from judgment. Do not use em dashes.
- Ask when requirements are genuinely ambiguous or a risky decision needs user input.
- Ask before force-pushing, merging, publishing, deploying, purchasing, transferring, changing account security, or taking irreversible actions unless explicitly authorized.
- Use Conventional Commits for commit messages and PR titles.
- Keep PR descriptions short: scope, implementation summary, and verification.

# Coding

- Read applicable instructions and relevant code before editing.
- Keep tickets, plans, acceptance criteria, and code lightweight. Limit scope to the requested outcome; acceptance criteria should verify that outcome, not add work.
- Validate untrusted input at boundaries; internally, rely on established contracts. Preserve required security and error handling.
- Summarize changes, verification, and anything not verified.
- Document only non-obvious, durable usage and operational requirements; correct inaccuracies. Keep ticket references, implementation history, and one-off verification or migration details in PRs/issues, not code or repository docs.

# Delegation

- Handle straightforward tasks directly. Delegate only when the benefit outweighs coordination cost, with bounded scope and checks.

# Security and privacy

- Never expose secrets or unnecessary personal or confidential data in prompts, repositories, docs, or tool output.
- Use least-privilege access and established secret storage. Check repositories for secrets before pushing or publishing.
- Never ask for passwords or 2FA codes, let the user authenticate.

# Browser use

- To "open" a URL, use `/usr/bin/open` on macOS or `xdg-open` on Linux, not browser automation.
- Use `chrome-isolated` for public pages and unauthenticated testing, never login or SSO.
- Use `chrome-user-profile` only for authorized authenticated access. Avoid exposing unrelated sensitive tabs.
