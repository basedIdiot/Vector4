--!strict
local Vector4 = {}

local TYPE_STRING: string = "Vector4"

-- to make typechecker happy
local function CalculateMagnitude(self: Vector4Type): number
	return math.sqrt(self.X^2 + self.Y^2 + self.Z^2 + self.W^2)
end
local function CalculateLerp(x0: number, y0: number, x1: number, y1: number, x: number): number
	return y0 * (1 - (x - x0) / (x1 - x0)) + y1 * (1 - (x1 - x) / (x1 - x0))
end


local function MultiplyVector4(self: Vector4Type, value: Vector4Type | number): Vector4Type
	if typeof(value) == "number" then
		return Vector4.new(self.X * value, self.Y * value, self.Z * value, self.W * value)
	end
	if typeof(value) ~= "table" then
		error(string.format("Attempted to add %s and %s", TYPE_STRING, typeof(value)))
	end
	local value: Vector4Type = (value:: Vector4Type)
	return Vector4.new(value.X * self.X, value.Y * self.Y, value.Z * self.Z, value.W * self.W)
end

local function DivideVector4(self: Vector4Type, value: Vector4Type | number): Vector4Type
	if typeof(value) == "number" then
		return Vector4.new(self.X / value, self.Y / value, self.Z / value, self.W / value)
	end
	if typeof(value) ~= "table" then
		error(string.format("Attempted to add %s and %s", TYPE_STRING, typeof(value)))
	end
	local value: Vector4Type = (value:: Vector4Type)
	return Vector4.new(value.X / self.X, value.Y / self.Y, value.Z / self.Z, value.W / self.W) 
end

Vector4.__index = function(self: Vector4Type, key): any
	-- We can't precompute the Unit Vector, since the unit vector would require
	-- it's own unit vector, which would need another unit vector blah blah
	-- causing a stack overflow
	if key == "Unit" then
		
		return DivideVector4(self, CalculateMagnitude(self))
	elseif key == "Magnitude" then
		return CalculateMagnitude(self)
	else
		return Vector4[key]
	end
	
end
Vector4.__add = function(self: Vector4Type, value: Vector4Type)
	if typeof(value) ~= "table" then
		error(string.format("Attempted to add %s and %s", TYPE_STRING, typeof(value)))
	end
	return Vector4.new(value.X + self.X, value.Y + self.Y, value.Z + self.Z, value.W + self.W)
end
Vector4.__mul = MultiplyVector4

Vector4.__sub = function(self: Vector4Type, value: Vector4Type)
	if typeof(value) ~= "table" then
		error(string.format("Attempted to subtract %s and %s", TYPE_STRING, typeof(value)))
	end
	return Vector4.new(value.X - self.X, value.Y - self.Y, value.Z - self.Z, value.W - self.W)
end

Vector4.__div = DivideVector4

Vector4.__tostring = function(self)
	return string.format("{%s, %s, %s, %s}", tostring(self.X), tostring(self.Y), tostring(self.Z), tostring(self.W))
end
Vector4.__newindex = function(self, key, value)
	error(string.format("Attempted to set %s of %s to %s.", key, tostring(self), tostring(value)))
end

export type Vector4Type = {
	X: number,
	Y: number,
	Z: number,
	W: number,
	__type: string,
	-- Needed to allow error less indexing of Magnitude and Unit
	Magnitude: number?,
	Unit: Vector4Type?
}
function Vector4.new(X: number?, Y: number?, Z: number?, W: number?): Vector4Type
	local X: number = X or 0
	local Y: number = Y or 0
	local Z: number = Z or 0
	local W: number = W or 0
	local self: Vector4Type = {
		X = X,
		Y = Y,
		Z = Z,
		W = W,
		__type = TYPE_STRING
	}
	return setmetatable(self, Vector4)
end

function Vector4:Dot(OtherVector4: Vector4Type): number
	return OtherVector4.X * self.X + OtherVector4.Y * self.Y + OtherVector4.Z * self.Z + OtherVector4.W * self.W
end
function Vector4:FuzzyEq(OtherVector4: Vector4Type, Epsilon: number?): boolean
	local Epsilon: number = Epsilon or 0.001
	for key: string, value: number in pairs(OtherVector4) do
		if key == "__type" then continue end
		if math.abs(value - OtherVector4[key]) <= Epsilon then
			return true
		end
	end
	return false
end
function Vector4:GetComponents(): (number, number, number, number)
	return self.X, self.Y, self.Z, self.W
end
function Vector4:Lerp(EndVector4: Vector4Type, Alpha: number?): Vector4Type
	local Alpha: number = Alpha or 0.5
	
	local x0: number = self.X
	local x1: number = EndVector4.X
	
	local y0: number = self.Y
	local y1: number = EndVector4.Y
	
	local z0: number = self.Z
	local z1: number = EndVector4.Z
	
	local w0: number = self.W
	local w1: number = EndVector4.W
	
	local Alpha: number = x1 - x0 * Alpha
	local y = CalculateLerp(x0, y0, x1, y1, Alpha)
	local z = CalculateLerp(x0, z0, x0, z0, Alpha)
	local w = CalculateLerp(x0, w0, x1, w1, Alpha)
	return Vector4.new(Alpha, y, z, w)
end
return Vector4
