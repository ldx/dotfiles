# MCP setup on a new laptop

1. Install `uv` and ensure `uvx` is on Pi's PATH.
2. Copy `dotfiles/.config/mcp/mcp.json` to `~/.config/mcp/mcp.json` as a regular
   file. Preserve any existing local configuration.
3. Create the private runtime directory:

   ```sh
   mkdir -p "$HOME/.local/share/workspace-mcp/credentials" "$HOME/.pi/agent"
   chmod 700 "$HOME/.local/share/workspace-mcp" "$HOME/.local/share/workspace-mcp/credentials"
   ```

4. Create or merge `~/.pi/agent/mcp-adapter.json` using the example below. Replace all
   `EXAMPLE_*` values and the email locally. Never commit this file or tokens.

   ```json
   {
     "mcpServers": {
       "google-workspace": {
         "env": {
           "GOOGLE_OAUTH_CLIENT_ID": "!op read 'op://EXAMPLE_VAULT/EXAMPLE_ITEM/EXAMPLE_ID_FIELD'",
           "GOOGLE_OAUTH_CLIENT_SECRET": "!op read 'op://EXAMPLE_VAULT/EXAMPLE_ITEM/EXAMPLE_SECRET_FIELD'",
           "GOOGLE_OAUTH_REDIRECT_URI": "http://localhost:8000/oauth2callback",
           "WORKSPACE_MCP_PORT": "8000",
           "WORKSPACE_MCP_CREDENTIALS_DIR": "${HOME}/.local/share/workspace-mcp/credentials",
           "USER_GOOGLE_EMAIL": "you@example.com"
         }
       }
     }
   }
   ```

   **1Password:** unlock/sign in to `op` before connecting.
   **macOS Keychain:** replace each `!op read ...` value with
   `!/usr/bin/security find-generic-password -s 'EXAMPLE_SERVICE' -a 'EXAMPLE_ACCOUNT' -w`,
   using the corresponding account for the client ID or secret.

   ```sh
   chmod 600 "$HOME/.pi/agent/mcp-adapter.json"
   ```

5. In the intended Google Cloud project, enable the standard Gmail, Drive, Docs,
   and Calendar APIs. Use a Web application OAuth client with the exact redirect
   URI above, and store its matching client ID and secret in your chosen password
   store. If port `8000` is occupied, change it in both the local config and
   registered redirect.
6. Run `/reload`, ask Pi to connect `google-workspace`, and complete Google
   authorization in your browser. Test inbox, file, document, and calendar reads.

## Keep the split

The shared file defines the read-only server. The local file selects credentials
and takes precedence. The adapter replaces the entire `env` object, so keep all its fields
in the local override. Tokens stay in the private runtime directory; do not sync it.

On an existing laptop, privately back up and compare configs first. Preserve
local-only servers, remove duplicated shared settings and obsolete Google preview
connectors, and keep only the Workspace `env` override locally. Future dotfile
updates must preserve `~/.pi/agent/mcp-adapter.json`. See [SETUP.md](../SETUP.md).

## Migrate older adapter overrides

Pi now reserves `~/.pi/agent/mcp.json` for its built-in MCP loader. The adapter
reads `~/.pi/agent/mcp-adapter.json` instead. If the old file contains only
adapter settings, rename it when the new path does not exist; otherwise merge
its adapter entries into the new file. Keep any intentional built-in MCP entries
in `mcp.json`, and remove migrated adapter entries from that file.

Adapter settings such as `auth: "oauth"` and partial `env` overrides are not
valid standalone built-in server definitions. Do not convert them or duplicate
servers across both loaders merely to suppress warnings. Run `/reload` after
migration, then use `/mcp-adapter` to check server status and connections.
