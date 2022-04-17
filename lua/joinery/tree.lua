local M = {}

function M.find_parent_with(node, predicate)
  if node:parent() and predicate(node:parent()) then
    return M.find_parent_with(node:parent(), predicate)
  else
    return node
  end
end

function M.get_child_by_type(node, type)
  for child, field in node:iter_children() do
    if child:type() == type then
      return child
    end
  end
end

function M.filter_children(node, predicate)
  local new_list = {}
  for child, field in node:iter_children() do
    if predicate(child) then
      table.insert(new_list, child)
    end
  end
  return new_list
end

return M
