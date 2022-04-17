function map(table, fn)
  local t = {}
  for index, value in pairs(table) do
    t[index] = fn(value)
  end
  return t
end

function contains(table, match)
  for index, value in ipairs(table) do
    if value == match then
      return true
    end
  end
  return false
end

