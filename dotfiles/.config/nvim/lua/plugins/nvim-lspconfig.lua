return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      eslint = {},
      vtsls = {
        settings = {
          experimental = {
            completion = {
              enableServerSideFuzzyMatch = true,
              entriesLimit = 200,
            },
          },
        },
      },
    },
    setup = {
      eslint = function()
        require("lazyvim.util").lsp.on_attach(function(client)
          if client.name == "eslint" then
            client.server_capabilities.documentFormattingProvider = true
          elseif client.name == "tsserver" then
            client.server_capabilities.documentFormattingProvider = false
          end
        end)
      end,
    },
  },
}
