# MCP setup on a new laptop

Pi uses its built-in MCP support. Do not load `pi-mcp-adapter` alongside it.

1. Install `uv` and ensure `uvx` is on Pi's PATH.
2. Use `dotfiles/.config/mcp/mcp.json` as the non-secret template for
   `~/.pi/agent/mcp.json`. On an existing machine, merge server definitions into
   that file, preserving local-only servers, credentials, and other local settings.
   Pi does not automatically load `~/.config/mcp/mcp.json`.
3. Create the private runtime directory:

   ```sh
   mkdir -p "$HOME/.local/share/workspace-mcp/credentials" "$HOME/.pi/agent"
   chmod 700 "$HOME/.local/share/workspace-mcp" "$HOME/.local/share/workspace-mcp/credentials"
   ```

4. Add this `env` object to the complete `google-workspace` entry in
   `~/.pi/agent/mcp.json`. Keep its `command`, `args`, and `cwd` from the template.
   Replace all `EXAMPLE_*` values and the email locally. Never commit local
   credentials or tokens.

   ```json
   {
     "GOOGLE_OAUTH_CLIENT_ID": "!op read 'op://EXAMPLE_VAULT/EXAMPLE_ITEM/EXAMPLE_ID_FIELD'",
     "GOOGLE_OAUTH_CLIENT_SECRET": "!op read 'op://EXAMPLE_VAULT/EXAMPLE_ITEM/EXAMPLE_SECRET_FIELD'",
     "GOOGLE_OAUTH_REDIRECT_URI": "http://localhost:8000/oauth2callback",
     "WORKSPACE_MCP_PORT": "8000",
     "WORKSPACE_MCP_CREDENTIALS_DIR": "${HOME}/.local/share/workspace-mcp/credentials",
     "USER_GOOGLE_EMAIL": "you@example.com"
   }
   ```

   **1Password:** unlock/sign in to `op` before connecting.
   **macOS Keychain:** replace each `!op read ...` value with
   `!/usr/bin/security find-generic-password -s 'EXAMPLE_SERVICE' -a 'EXAMPLE_ACCOUNT' -w`,
   using the corresponding account for the client ID or secret.

   ```sh
   chmod 600 "$HOME/.pi/agent/mcp.json"
   ```

5. In the intended Google Cloud project, enable the standard Gmail, Drive, Docs,
   and Calendar APIs. Use a Web application OAuth client with the exact redirect
   URI above, and store its matching client ID and secret in your chosen password
   store. If port `8000` is occupied, change it in both the local config and
   registered redirect.
6. Restart Pi after removing the adapter, or use `/reload` for subsequent config
   changes. Run `pi mcp list` or `/mcp` to check connections. Complete Google
   authorization in your browser when requested by Workspace tools, then test
   inbox, file, document, and calendar reads.

## Local configuration and migration

The shared template defines the read-only Workspace command. The complete runtime
configuration at `~/.pi/agent/mcp.json` is machine-local and must be preserved
when applying dotfiles. Tokens stay in the private runtime directory; do not sync
it. See [SETUP.md](../SETUP.md).

When migrating from the adapter, merge shared server definitions and any local
`mcp-adapter.json` overrides into `~/.pi/agent/mcp.json`. Every server needs a
`command` or `url`; a standalone `env` override is not sufficient. Remove adapter
fields such as `lifecycle` and `auth: "oauth"`. Built-in MCP discovers HTTP OAuth
automatically and connects enabled servers at startup rather than lazily.

Remove `npm:pi-mcp-adapter` from all selectable Pi profiles. Built-in MCP is enabled
by default; check Built-in extensions in `pi config` if it was explicitly disabled.
Remote servers may need a fresh sign-in with `/mcp` or `pi mcp login <server>` because
the built-in loader uses a separate OAuth credential store. Preserve existing
Workspace credentials; switching loaders does not require deleting them.
