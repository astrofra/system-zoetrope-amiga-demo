Quantize = function(val, steps)
  steps = steps or 16
  val = val*steps
  val = math.floor(val/steps)
  return val
end

RangeAdjust = function(val, in_lower, in_upper, out_lower, out_upper)
  return (val-in_lower)/(in_upper-in_lower)*(out_upper-out_lower)+out_lower
end

Clamp = function(x, in_lower, in_upper)
  return math.min(math.max(x, in_lower), in_upper)
end

mapValueToArray = function(val, in_lower, in_upper, mapping_array)
	local val = RangeAdjust(val, in_lower, in_upper, 0.0, 1.0)
	val = Clamp(val, 0.0, 1.0)
	local array_pos = val*(#mapping_array-1)
	local ceil_pos = math.ceil(array_pos)
	local floor_pos = math.floor(array_pos)
	return mapping_array[floor_pos + 1]*(ceil_pos-array_pos) + mapping_array[ceil_pos + 1]*(1.0-(ceil_pos-array_pos))
end

stringToList = function(str)
  local t = {}
  for i = 1, #str do
    t[i] = str:sub(i, i)
  end
  return t
end


