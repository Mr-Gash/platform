ENT.Base = "base_brush"
ENT.Type = "brush"
AddCSLuaFile()
AccessorFunc( ENT, "CPNumber", "Number" )
AccessorFunc( ENT, "PuzTitle", "Title" )

function ENT:Initialize() end
function ENT:Draw() end

function ENT:StartTouch( entity )
	gamemode.Call( "ReachedCheckpoint", entity, self:GetNumber(), self:GetTitle() )
end

function ENT:KeyValue( key, value )
	if key == "number" then
		self:SetNumber( tonumber( value ) )
	elseif key == "title" then
		self:SetTitle( value )
	end
end