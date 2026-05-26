local M = {}

local function debug_children(node)
  for child, field in node:iter_children() do
    if node == child then
      print(field, child:type(), "(currrent)")
    elseif child:named() then
      print(field, child:type())
    -- else
    --   print("unnamed node", node:type())
    end
  end
end

function M.debug_node(node)
  local text = vim.treesitter.get_node_text(node, 0)
  local first_line = vim.split(text, "\n")[1]
  print(string.format("%s Text: \"%s\"", node:type(), first_line))
  print("Children...")
  debug_children(node)

  if node:parent() then
    print(node:parent():type())
    print("Parent's children...")
    debug_children(node)
  else
    print("No parent")
  end
end

return M
