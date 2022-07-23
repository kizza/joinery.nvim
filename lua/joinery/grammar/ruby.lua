local tree = require "joinery.tree"

local M = {}

function M.get_callable_scope(current_node)
  -- Find first foothold
  while current_node and current_node:type() ~= "call" do
    current_node = current_node:parent()
  end

  if not current_node then
    return nil
  end

  -- Expand to broader scope
  local is_callable = function(node) return node:type() == "call" or node:type() == "argument_list" end
  return tree.find_parent_with(current_node, is_callable)
end

return M
