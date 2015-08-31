 	
ENT.Type 		= "brush"

AddCSLuaFile( "shared.lua" )
AccessorFunc( ENT, "CPNumber", "Number" )

//Do nothing when initializing
function ENT:Initialize()
end

//We need to catch the number value
function ENT:KeyValue( key, value )
	if ( key == "number" ) then
		self:SetNumber( tonumber(value) )
	end
end