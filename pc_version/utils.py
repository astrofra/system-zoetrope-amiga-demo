from math import ceil, floor


def Quantize(val, steps=16):
	val *= steps
	val = int(val) / steps
	return val


def RangeAdjust(val, in_lower, in_upper, out_lower, out_upper):
    return (val - in_lower) / (in_upper - in_lower) * (out_upper - out_lower) + out_lower


def Clamp(x, in_lower, in_upper):
	return min((max(x, in_lower)), in_upper)


def mapValueToArray(val, in_lower, in_upper, mapping_array):
	val = RangeAdjust(val, in_lower, in_upper, 0.0, 1.0)
	val = Clamp(val, 0.0, 1.0)
	array_pos = val * (len(mapping_array) - 1)
	ceil_pos = ceil(array_pos)
	floor_pos = floor(array_pos)
	return mapping_array[floor_pos] * float(ceil_pos - array_pos) + mapping_array[ceil_pos] * (1.0 - (float(ceil_pos - array_pos)))