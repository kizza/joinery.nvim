set nocompatible
set nobackup
set nowb
set noswapfile

let g:joinery_vimrc_loaded = 1

let s:plugin = expand('<sfile>:h:h:h')

execute 'set runtimepath+='.s:plugin

" Add nvim-treesitter for parser .so files but disable its plugin loading
let g:loaded_nvim_treesitter = 1
execute 'set runtimepath+='.s:plugin.'/node_modules/nvim-treesitter'

execute 'cd '.s:plugin

" Start treesitter parser when filetype is set
autocmd FileType ruby,javascript lua vim.treesitter.start()
