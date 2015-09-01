ENT.Type = "brush"

AddCSLuaFile( "shared.lua" )
AccessorFunc( ENT, "CPNumber", "Number" )

function ENT:Initialize() end

function ENT:KeyValue( key, value )
	if key == "number" then
		self:SetNumber( tonumber(value) )
	end
end