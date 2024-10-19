require("python")

vim.api.nvim_set_keymap("n", "<C-_>", ":lua require('python').toggle_comment()<CR>", { noremap = true, silent = true })

require("packer").startup(function(use)
    use "wbthomason/packer.nvim"
    use "tpope/vim-fugitive"
    use "nvim-tree/nvim-tree.lua"
    use "neovim/nvim-lspconfig"
    use {
        "hrsh7th/nvim-cmp",
        requires = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip"
        }
    }
    use {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate"
    }
    use {
        "jose-elias-alvarez/null-ls.nvim",
        requires = { "nvim-lua/plenary.nvim" }
    }
    use "mfussenegger/nvim-dap"
    use "mfussenegger/nvim-dap-python"
end)

require("nvim-tree").setup()

-- LSP Config Setup
local lspconfig = require("lspconfig")
lspconfig.pyright.setup({})

-- Autocompletion setup
local cmp = require("cmp")
cmp.setup({
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body) -- For luasnip users
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item.
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "path" }
    })
})

-- Use buffer source for `/` and `?`
cmp.setup.cmdline({ "/", "?" }, {
    sources = {
        { name = "buffer" }
    }
})

-- Syntax Highlighting
require("nvim-treesitter.configs").setup {
    ensure_installed = "python",
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}

-- Linting and formatting
local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        null_ls.builtins.diagnostics.ruff,  -- for linting
        null_ls.builtins.formatting.ruff,  -- for formatting
    },
})

-- Keybinding to format the current buffer
vim.api.nvim_set_keymap("n", "<Leader>f", "<Cmd>lua vim.lsp.buf.format()<CR>", { noremap = true, silent = true })

-- Autoformat on save
vim.cmd [[
    augroup FormatAutogroup
        autocmd!
        autocmd BufWritePost *.py lua vim.lsp.buf.format()
    augroup END
]]

-- LSP Keybindings
local on_attach = function(_, bufnr)
    local opts = { noremap=true, silent=true }
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
end

-- Debugging setup for Python
local dap = require("dap")

-- Python DAP adapter
dap.adapters.python = {
    type = 'executable',
    command = '/path/to/your/venv/bin/python',  -- Update with the correct path
    args = { '-m', 'debugpy.adapter' },  -- Use comma instead of semicolon
}

dap.configurations.python = {
    {
        type = "python",
        request = "launch",
        name = "Launch file",
        program = "${file}",  -- This runs the current file
        pythonPath = function()
            return '/path/to/your/venv/bin/python'  -- Adjust path as necessary
        end,
    },
}

-- Keybindings for DAP
vim.api.nvim_set_keymap('n', '<F5>', ":lua require'dap'.continue()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F10>', ":lua require'dap'.step_over()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F11>', ":lua require'dap'.step_into()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F12>', ":lua require'dap'.step_out()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>b', ":lua require'dap'.toggle_breakpoint()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>lp', ":lua require'dap'.run_last()<CR>", { noremap = true, silent = true })

-- Note: Removed the auto command for activating the virtual environment
