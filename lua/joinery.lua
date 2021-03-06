local ts_utils = require "nvim-treesitter.ts_utils"
local ranges = require "joinery.ranges"
local tree = require "joinery.tree"
require "joinery.util"

local M = {}

local function get_callable_scope()
  local current_node = ts_utils.get_node_at_cursor()
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
  return map(ranges, function(range) return {ts_utils.get_vim_range(range)} end)
end

function M.highlight()
  local node = get_callable_scope()
  if not node then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local ranges = get_partitioned_ranges(node)
  ts_utils.update_selection(bufnr, node)
end

return M
