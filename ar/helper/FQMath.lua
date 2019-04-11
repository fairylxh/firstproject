FQMath = {}

FQMath.epsilon = 0.000000001
FQMath.x_axis = 1
FQMath.y_axis = 2
FQMath.z_axis = 3

function FQMath:vector_length(vec)
	local dot = vec.x * vec.x + vec.y * vec.y + vec.z * vec.z
	return math.sqrt(dot)
end

function FQMath:vector_distance(vec1, vec2)
	local vec = vec1 - vec2
	local dot = vec.x * vec.x + vec.y * vec.y + vec.z * vec.z
	return math.sqrt(dot)
end

function FQMath:vector_normal(vec)
	local dot = vec.x * vec.x + vec.y * vec.y + vec.z * vec.z
	local lenRcp = math.sqrt(dot)
	local v = Vector3(0,0,0)
	if lenRcp ~= 0 then
		lenRcp = 1.0 / lenRcp
		v.x = vec.x * lenRcp
		v.y = vec.y * lenRcp
		v.z = vec.z * lenRcp
	end
	return v
end

function FQMath:vector_angle(v1, v2)
	local dx = v1.y * v2.z - v1.z * v2.y
	local dy = v1.z * v2.x - v1.x * v2.z
	local dz = v1.x * v2.y - v1.y * v2.x
	local dot = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
	local coss = v1.x * v2.y + v2.x * v1.y

	local sign = 1
	if coss ~= 0 then
		sign = coss / math.abs(coss)
	end

	local angle = math.atan2(math.sqrt(dx * dx + dy * dy + dz * dz) + FQMath.epsilon, dot)
	return angle * (180 / math.pi) * -sign
end

function FQMath:vector_rotate(vec, angle, axis)
	local x = vec.x
	local y = vec.y
	local z = vec.z
	angle = angle * (math.pi / 180)

	if axis == self.x_axis then
		z = vec.z * math.cos(angle) - vec.y * math.sin(angle)
		y = vec.z * math.sin(angle) + vec.y * math.cos(angle)
	elseif axis == self.y_axis then
		x = vec.x * math.cos(angle) - vec.z * math.sin(angle)
		z = vec.x * math.sin(angle) + vec.z * math.cos(angle)
	elseif axis == self.z_axis then
		x = vec.x * math.cos(angle) - vec.y * math.sin(angle)
		y = vec.x * math.sin(angle) + vec.y * math.cos(angle)
	end

	return Vector3(x, y, z)
end