ENT.Base = "base_brush"
ENT.Type = "brush"
AddCSLuaFile()
AccessorFunc( ENT, "CPNumber", "Number" )
AccessorFunc( ENT, "PuzTitle", "Title" )

//Do nothing when initializing
function ENT:Initialize()
	print( self )
end

//When the player touches a checkpoint
function ENT:StartTouch( entity )
	gamemode.Call( "ReachedCheckpoint", entity, self:GetNumber(), self:GetTitle() )
end

function ENT:Draw()
	local mins, maxs = self:GetCollisionBounds()
	print( mins, maxs )
end

//We need to catch the number value
function ENT:KeyValue( key, value )
	if key == "number" then
		self:SetNumber( tonumber( value ) )
	end
	if key == "title" then
		self:SetTitle( value )
	end
end