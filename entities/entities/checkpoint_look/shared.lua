ENT.Type = "brush"
-- this is 100% the same as checkpoint_spawn. why do we use a goddamn brush entity for this? fix it.
AddCSLuaFile( "shared.lua" )
AccessorFunc( ENT, "CPNumber", "Number" )

function ENT:Initialize() end

function ENT:KeyValue( key, value )
	if key == "number" then
		self:SetNumber( tonumber(value) )
	end
end