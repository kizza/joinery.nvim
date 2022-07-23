local tree = require "joinery.tree"

local M = {}

function M.get_callable_scope(current_node)
  -- Find first foothold
  while current_node and current_node:type():match("expression") == nil do
    current_node = current_node:parent()
  end

  if not current_node then
    return nil
  end

  -- Expand to broader scope
  local is_expression = function(node) return node:type():match("expression") ~= nil end
  return tree.find_parent_with(current_node, is_expression)
end

return M
