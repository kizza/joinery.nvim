local M = {}

-- Merges two range tables
function M.merge_ranges(range1, range2)
  local srow1, scol1, erow1, ecol1 = unpack(range1)
  local srow2, scol2, erow2, ecol2 = unpack(range2)

  -- Start line/column
  if srow1 == srow2 then
    srow = srow1
    scol = math.min(scol1, scol2)
  elseif srow1 < srow2 then
    srow = srow1
    scol = scol1
  else
    srow = srow2
    scol = scol2
  end

  -- Start line/column
  if erow1 == erow2 then
    erow = erow1
    ecol = math.max(ecol1, ecol2)
  elseif erow2 > erow1 then
    erow = erow2
    ecol = ecol2
  else
    erow = erow1
    ecol = ecol1
  end

  return srow, scol, erow, ecol
end

function M.merge_children(children)
  local merged
  for index, item in ipairs(children) do
    if index == 1 then
      merged = {item:range()}
    else
      merged = { M.merge_ranges(merged, {item:range()}) }
    end
  end
  return merged
end

return M
