--!strict
local Vector4 = {}

local TYPE_STRING: string = "Vector4"
local COORDINATE_ARRAY = {
	x = "X",
	y = "Y",
	z = "Z",
	w = "W",
}
-- to make typechecker happy
local function CalculateMagnitude(self: Vector4): number
	return math.sqrt(self.X^2 + self.Y^2 + self.Z^2 + self.W^2)
end
local function Lerp(v0: number, v1: number, t: number): number 
	return (1 - t) * v0 + t * v1
end
local function OrderArgs(Value1: number | Vector4, Value2: number | Vector4): (Vector4, number | Vector4)
	if typeof(Value1) == "number" then
		local Value1 = (Value1 :: number)
		local Value2 = (Value2 :: Vector4)
		return Value2, Value1
	end
	local Value2 = (Value2 :: number)
	local Value1 = (Value1 :: Vector4)
	return Value1, Value2
end
local function IsWithinEpsilon(Value1: number, Value2: number, Epsilon: number): boolean
	if math.abs(Value1 - Value2) >= Epsilon then
		return false
	end
	return true
end
local function MultiplyVector4(self: Vector4, value: Vector4 | number): Vector4
	local self, value = OrderArgs(self, value)
	if typeof(value) == "number" then
		return Vector4.new(self.X * value, self.Y * value, self.Z * value, self.W * value)
	end
	if typeof(value) ~= "table" then
		error(string.format("Attempted to multiply %s and %s", TYPE_STRING, typeof(value)))
	end
	local value: Vector4 = (value :: Vector4)
	print(value)
	print(self)
	return Vector4.new(value.X * self.X, value.Y * self.Y, value.Z * self.Z, value.W * self.W)
end

local function DivideVector4(self: Vector4 | number, value: Vector4 | number): Vector4
	
	if typeof(self) == "number" then
		error(string.format("Attempted to divide number and %s", TYPE_STRING))
	end
	local self, value = OrderArgs(self, value)

	if typeof(value) == "number" then
		local self = (self :: Vector4)
		return Vector4.new(self.X / value, self.Y / value, self.Z / value, self.W / value)
	end
	if typeof(value) ~= "table" then
		error(string.format("Attempted to divide %s and %s", TYPE_STRING, typeof(value)))
	end
	local value: Vector4 = (value:: Vector4)
	return Vector4.new(value.X / self.X, value.Y / self.Y, value.Z / self.Z, value.W / self.W) 
end

Vector4.__index = function(self: Vector4, key): any
	-- We can't precompute the Unit Vector, since the unit vector would require
	-- it's own unit vector, which would need another unit vector blah blah
	-- causing a stack overflow
	if key == "Unit" then
		
		return DivideVector4(self, CalculateMagnitude(self))
	elseif key == "Magnitude" or key == "magnitude" then
		return CalculateMagnitude(self)
	else
		return rawget(self, COORDINATE_ARRAY[key]) or Vector4[key]
	end
	
end
Vector4.__add = function(self: Vector4, value: Vector4)
	if typeof(value) ~= "table" then
		error(string.format("Attempted to add %s and %s", TYPE_STRING, typeof(value)))
	end
	return Vector4.new(value.X + self.X, value.Y + self.Y, value.Z + self.Z, value.W + self.W)
end
Vector4.__mul = MultiplyVector4

Vector4.__sub = function(self: Vector4, value: Vector4)
	if typeof(value) ~= "table" then
		error(string.format("Attempted to subtract %s and %s", TYPE_STRING, typeof(value)))
	end
	return Vector4.new(self.X - value.X, self.Y - value.Y, self.Z - value.Z, self.W - value.W)
end

Vector4.__div = DivideVector4

Vector4.__unm = function(self: Vector4)
	return Vector4.new(-self.X, -self.Y, -self.Z, -self.W)
end
Vector4.__eq = function(self: Vector4, value): boolean
	if typeof(value) ~= "table" then return false end
	if value.__type ~= TYPE_STRING then return false end
	if self.X ~= value.X then return false end
	if self.Y ~= value.Y then return false end
	if self.Z ~= value.Z then return false end
	if self.W ~= value.W then return false end
	return true
end
Vector4.__tostring = function(self)
	return string.format("{%s, %s, %s, %s}", tostring(self.X), tostring(self.Y), tostring(self.Z), tostring(self.W))
end
Vector4.__newindex = function(self, key, value)
	error(string.format("Attempted to set %s of %s to %s.", key, tostring(self), tostring(value)))
end

export type Vector4 = {
	X: number,
	Y: number,
	Z: number,
	W: number,
	__type: string,
	
	Magnitude: number?,
	Unit: Vector4?,
	
	__add: nil | (Vector4) -> Vector4,
	__sub: nil | (Vector4) -> Vector4,
	__mul: nil | (Vector4 | number) -> Vector4,
	__div: nil | (Vector4 | number) -> Vector4,
	
	Lerp: nil | (Vector4, number?) -> Vector4,
	Dot: nil | (Vector4, Vector4) -> number,
	FuzzyEq: nil | (Vector4, number?) -> boolean,
	GetComponents: nil | () -> (number, number, number, number),
	GetAngleBetweenVectors: nil | (Vector4) -> number,
	Project: nil | (Vector4) -> Vector4,
}

function Vector4.new(X: number?, Y: number?, Z: number?, W: number?): Vector4
	local X: number = X or 0
	local Y: number = Y or 0
	local Z: number = Z or 0
	local W: number = W or 0
	local self: Vector4 = {
		X = X,
		Y = Y,
		Z = Z,
		W = W,
		__type = TYPE_STRING
	}

	return setmetatable(self, Vector4)
end

function Vector4:Dot(OtherVector4: Vector4): number
	return OtherVector4.X * self.X + OtherVector4.Y * self.Y + OtherVector4.Z * self.Z + OtherVector4.W * self.W
end
function Vector4:FuzzyEq(OtherVector4: Vector4, Epsilon: number?): boolean
	if typeof(OtherVector4) ~= "table" then return false end
	if OtherVector4.__type ~= TYPE_STRING then return false end
	local Epsilon: number = Epsilon or 0.001
	
	local x0: number = self.X
	local x1: number = OtherVector4.X

	local y0: number = self.Y
	local y1: number = OtherVector4.Y

	local z0: number = self.Z
	local z1: number = OtherVector4.Z

	local w0: number = self.W
	local w1: number = OtherVector4.W
	
	if not IsWithinEpsilon(w0, w1, Epsilon) then
		return false
	end
	if not IsWithinEpsilon(z0, z1, Epsilon) then
		return false
	end
	if not IsWithinEpsilon(y0, y1, Epsilon) then
		return false
	end
	if not IsWithinEpsilon(z0, z1, Epsilon) then
		return false
	end
	
	return true
end
function Vector4:GetComponents(): (number, number, number, number)
	return self.X, self.Y, self.Z, self.W
end
function Vector4:Lerp(EndVector4: Vector4, Alpha: number?): Vector4
	local Alpha: number = Alpha or 0.5
	
	local x0: number = self.X
	local x1: number = EndVector4.X
	
	local y0: number = self.Y
	local y1: number = EndVector4.Y
	
	local z0: number = self.Z
	local z1: number = EndVector4.Z
	
	local w0: number = self.W
	local w1: number = EndVector4.W
	
	local x = Lerp(x0, x1, Alpha)
	local y = Lerp(y0, y1, Alpha)
	local z = Lerp(z0, z1, Alpha)
	local w = Lerp(w0, w1, Alpha)
	return Vector4.new(x, y, z, w)
end
function Vector4:GetAngleBetweenVectors(OtherVector4: Vector4): number
	return math.acos(self:Dot(OtherVector4) / (self.Magnitude * OtherVector4.Magnitude))
end
function Vector4:Project(OtherVector4: Vector4): Vector4
	return (self:Dot(OtherVector4) / self.Magnitude ^ 2) * self
end
return Vector4
