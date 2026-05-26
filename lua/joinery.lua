local ranges = require "joinery.ranges"
local tree = require "joinery.tree"
require "joinery.util"

local M = {}

local function get_vim_range(range)
  local srow, scol, erow, ecol = unpack(range)
  srow = srow + 1
  scol = scol + 1
  erow = erow + 1

  if ecol == 0 then
    erow = erow - 1
    ecol = vim.fn.col { erow, "$" } - 1
  end
  return srow, scol, erow, ecol
end

local function get_callable_scope()
  local current_node = vim.treesitter.get_node()
  local grammar_module = "joinery.grammar."..(vim.api.nvim_eval("&filetype"))
  return require(grammar_module).get_callable_scope(current_node)
end

local function get_partitioned_ranges(node)
  -- Return as is if doens't contain "do_block"
  local do_block = tree.get_child_by_type(node, "do_block")
  if not do_block then
    return {{node:range()}}
  end

  -- Get filtered children
  local not_do_block = function(child) return child:named() and child:type() ~= "do_block" end
  local children = tree.filter_children(node, not_do_block)
  local merged = ranges.merge_children(children)
  return {merged, {do_block:range()}}
end

function M.get_partitioned_ranges()
  local node = get_callable_scope()
  if not node then
    return
  end

  local ranges = get_partitioned_ranges(node)
  return map(ranges, function(range) return {get_vim_range(range)} end)
end

function M.highlight()
  local node = get_callable_scope()
  if not node then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local ranges = get_partitioned_ranges(node)
  local start_row, start_col, end_row, end_col = node:range()
  vim.api.nvim_buf_set_mark(bufnr, "<", start_row + 1, start_col, {})
  vim.api.nvim_buf_set_mark(bufnr, ">", end_row + 1, end_col - 1, {})
  vim.cmd("normal! gv")
end

return M
