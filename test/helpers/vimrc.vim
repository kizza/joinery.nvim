set nocompatible
set nobackup
set nowb
set noswapfile

let g:joinery_vimrc_loaded = 1

let s:plugin = expand('<sfile>:h:h:h')

execute 'set runtimepath+='.s:plugin

execute 'set runtimepath+='.s:plugin.'/node_modules/nvim-treesitter'

execute 'cd '.s:plugin

lua << EOF
  require 'nvim-treesitter.configs'.setup {
    ensure_installed = { "ruby", "javascript" },
    sync_install = true,
  }
EOF
