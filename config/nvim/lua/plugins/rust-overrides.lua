return {
  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            cargo = {
              buildScripts = { enable = true },
              cfgs = { testbuild = vim.NIL },
              targetDir = vim.fn.expand("~/ra-target"),
              extraEnv = {
                RUSTFLAGS = "--cfg testbuild",
              },
            },
            check = {
              command = "clippy",
              extraArgs = { "--target-dir", vim.fn.expand("~/ra-target") },
            },
            procMacro = { enable = true },
            completion = {
              autoimport = { enable = true },
              autoself = { enable = true },
              postfix = { enable = true },
              callable = { snippets = "fill_arguments" },
              fullFunctionSignatures = { enable = true },
              privateEditable = { enable = true },
            },
            inlayHints = {
              bindingModeHints = { enable = false },
              chainingHints = { enable = true },
              closingBraceHints = { enable = true, minLines = 25 },
              closureReturnTypeHints = { enable = "with_block" },
              lifetimeElisionHints = { enable = "skip_trivial" },
              parameterHints = { enable = true },
              typeHints = { enable = true, hideClosureInitialization = true, hideNamedConstructor = true },
            },
            diagnostics = {
              styleLints = { enable = true },
            },
          },
        },
      },
    },
  },
}
