function Lerp(k, a, b)
	return (b - a) * k + a
end

function RangeAdjust(k, a, b, u, v)
	return (k - a) / (b - a) * (v - u) + u
end

function Clamp(v, mn, mx)
	if (v < mn) then return mn end
	if (v > mx) then return mx end
	return v
end
