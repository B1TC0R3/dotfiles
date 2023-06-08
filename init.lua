-- Vim Values
vim.o.number         = true
vim.o.relativenumber = true
vim.o.showmatch      = true
vim.o.hlsearch       = true
vim.o.virtualedit    = 'block'

vim.opt.list          = true
vim.opt.autoindent    = true
vim.opt.expandtab     = true
vim.opt.termguicolors = true
vim.opt.shiftwidth    = 4
vim.opt.tabstop       = 4

vim.cmd('filetype plugin on')

-- Plugins
-- Managed by vim.plug
local plug = vim.fn['plug#']
vim.call('plug#begin', '~/.config/nvim/plugged')

-- Dependencies
plug('nvim-lua/plenary.nvim')           -- System interface, async execution
plug('MunifTanjim/nui.nvim')            -- Nvim UI library
plug('nvim-treesitter/nvim-treesitter') -- Source code tree generator
plug('folke/neodev.nvim')               -- Nvim LUA Api completion

-- First Layer Plugins
plug('neovim/nvim-lspconfig')               -- Enables LSP Support
plug('nvim-tree/nvim-web-devicons')         -- Devicons for dashboard
plug('nvimdev/dashboard-nvim')              -- Dashboard
plug('jbyuki/venn.nvim')                    -- Draw Boxes/Arrows around existing text
plug('nvim-telescope/telescope.nvim')       -- Telescope (many functions)
plug('folke/noice.nvim')                    -- Complete UI overhaul
plug('lukas-reineke/indent-blankline.nvim') -- Indentation markers
plug('akinsho/bufferline.nvim')             -- Buffer display
plug('mfussenegger/nvim-dap')               -- Debugger
plug('rcarriga/nvim-dap-ui')                -- Better debugger UI
plug('RRethy/vim-illuminate')               -- Highlight selected word
plug('folke/noice.nvim')                    -- Nvim UI overhaul
plug('rcarriga/nvim-notify')                -- Better notification display

-- Completion engine
plug('hrsh7th/cmp-vsnip')
plug('hrsh7th/vim-vsnip')
plug('hrsh7th/cmp-nvim-lsp')
plug('hrsh7th/cmp-buffer')
plug('hrsh7th/cmp-path')
plug('hrsh7th/cmp-cmdline')
plug('hrsh7th/nvim-cmp')

-- Theme
plug('B1TC0R3/gruvbox')

-- For the Future
-- plug 'nvim-neo-tree/neo-tree.nvim'     -- File tree display
-- plug 'stevearc/dressing.nvim'          -- Do not fully understand what this does yet, some fancy renaming UI

vim.call('plug#end')


-- Dashboard
-- TODO: Do not display tablines in dashboard
local dashboard = require('dashboard')

dashboard.setup({
    theme = 'hyper',
    shortcut_type = 'number',
    config = {
        header = {
            "                                                                       ",
	        "                                                                     ",
	        "       ████ ██████           █████      ██                     ",
            "      ███████████             █████                             ",
            "      █████████ ███████████████████ ███   ███████████   ",
            "     █████████  ███    █████████████ █████ ██████████████   ",
            "    █████████ ██████████ █████████ █████ █████ ████ █████   ",
            "  ███████████ ███    ███ █████████ █████ █████ ████ █████  ",
            " ██████  █████████████████████ ████ █████ █████ ████ ██████ ",
            "                                                                       ",
            "",
        },
        shortcut = {
            {
                icon    = '󰊳 ',
                icon_hl = '@variable',
                desc    = 'Update',
                action  = 'PlugUpdate | sleep 1000m | q',
                key     = 'u',
            },
            {
                icon    = ' ',
                icon_hl = '@variable',
                desc    = 'Files',
                action  = 'Telescope find_files',
                key     = 'f',
            },
        },
        footer = {
            '',
            '🎵Hack all the things! 🎵'
        }
    }
})

vim.api.nvim_create_autocmd(
    'FileType',
    {
        pattern = 'dashboard',
        command = 'let b:indent_blankline_enabled = v:false'
    }
)

-- indent-blankline
local indent_blankline = require('indent_blankline')

indent_blankline.setup({
    use_treesitter = true,
    show_current_context = true,
    show_current_context_start = true,
})


-- Language Servers
local lsp = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lsp.lua_ls.setup {
    capabilties = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                globals = {'vim'}
            }
        }
    }
}
lsp.ccls.setup {
    capabilties = capabilities
}
lsp.pyright.setup {
    capabilties = capabilities
}
lsp.rust_analyzer.setup {
    capabilties = capabilities
}


-- Venn.N
function _G.Toggle_venn()
    local venn_enabled = vim.inspect(vim.b.venn_enabled)
    if venn_enabled == "nil" then
        vim.b.venn_enabled = true
        vim.cmd('setlocal ve=all')
        vim.api.nvim_buf_set_keymap(0, "n", "<S-down>", "<C-v>j:VBox<CR>", {noremap = true})
        vim.api.nvim_buf_set_keymap(0, "n", "<S-up>", "<C-v>k:VBox<CR>", {noremap = true})
        vim.api.nvim_buf_set_keymap(0, "n", "<S-right>", "<C-v>l:VBox<CR>", {noremap = true})
        vim.api.nvim_buf_set_keymap(0, "n", "<S-left>", "<C-v>h:VBox<CR>", {noremap = true})
        vim.api.nvim_buf_set_keymap(0, "v", "f", ":VBox<CR>", {noremap = true})
    else
        vim.cmd('setlocal ve=')
        vim.cmd('mapclear <buffer>')
        vim.b.venn_enabled = nil
    end
end

vim.api.nvim_set_keymap('n', '<leader>v', ":lua Toggle_venn()<CR>", {noremap = true})
Toggle_venn()


-- Bufferline
local bufferline = require('bufferline')
bufferline.setup {
    options = {
        separator_style = "slant",
    }
}


-- Cmp
local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn['vsnip#anonymous'](args.body)
        end,
    },
    sources = cmp.config.sources {
        { name = 'nvim_lsp' },
        { name = 'buffer' },
        { name = 'path' },
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<Tab>'] = cmp.mapping.confirm({ select = true }),
    }
})

cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' },
    }
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' },
        { name = 'cmdline' },
    })
})


-- Noice
local noice = require('noice')
noice.setup({
    lsp = {
        override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
        }
    }
})


-- Nvim Notify
local nvim_notify = require('notify')
nvim_notify.setup({
    background_colour = '#1d2021'
})
vim.notify = nvim_notify


-- Dap
-- TODO: Configure this, see ':help dap.txt'
local dap = require('dap')

dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-vscode',
    name = 'lldb'
}

dap.adapters.python = {
    type = 'executable',
    command = '/usr/bin/python',
    args = { '-m', 'debugpy.adapter' }
}

-- TODO: Add support for Rust

dap.configurations.c = {
    {
        name = 'C/CPP Debugger',
        type = 'lldb',
        request = 'launch',
        program = function()
            return '${file}'
            -- TODO: Find the executable in CWD (.dapconf file in project root?)
        end,
        stopOnEntry = false,
        cwd = '{$workspaceFolder}',
        args = {}
    }
}

dap.configurations.cpp = dap.configurations.c

dap.configurations.python = {
    {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        pythonPath = '/usr/bin/python',
    },
}


-- Dap UI
local dapui = require('dapui')

dapui.setup()

dap.listeners.after.event_initialized['dapui_config'] = function()
    dapui.open()
end

dap.listeners.before.even_terminated['dapui.config'] = function()
    dapui.close()
end

dap.listeners.before.event_exited['dapui.config'] = function()
    dapui.close()
end


-- Theme
vim.cmd('colorscheme gruvbox')
