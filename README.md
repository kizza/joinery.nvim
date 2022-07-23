# Joins code together (and splits it apart).
[![Tests](https://github.com/kizza/joinery.nvim/actions/workflows/tests.yml/badge.svg)](https://github.com/kizza/joinery.nvim/actions/workflows/tests.yml)0

Specifically joining lines of callable code into a single line, or splitting it into indented wrapped lines

<!-- ![example workflow](https://github.com/kizza/jump-from-treesitter.nvim/actions/workflows/tests.yml/badge.svg) -->

Will transform
```ruby
object.callable(with: :argument).method do
  # inner block
end
```

to...
```ruby
object
  .callable(with: :argument)
  .method do
    # inner block
  end
```

with ease (and back again!)

- Wouldn't be possible without the impressive functionality provided by [nvimtreesitter](https://github.com/nvim-treesitter/nvim-treesitter)
  (it uses Treesitter to scope the callable region)
- Inspired by the joy and effortless of using [Vim-ArgWrap](https://github.com/FooSoft/vim-argwrap)
  (I've used this for a while now, and makes formatting joyful and easy)

## Installation

Whatever method works for you.  I use [vim-plug](https://github.com/junegunn/vim-plug), so it's...

```vim
Plug 'kizza/joinery.nvim'
```

## Usage

With your cursor anywhere the intended scope of callable code
```vim
call joinery#execute()
```

You may wish to invoke it via a mapping such as:
```vim
nmap <silent> <leader>j :call joinery#execute()<CR>
```

## Dependencies

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (to parse the current cursor's token)

## Future plans

- To keep an eye on any issues and tweaks
- To be more explicitly inclusive of languages (currently working mostly in ruby)

