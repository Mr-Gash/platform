AddCSLuaFile( "cl_init.lua" )
IncludeCS( "shared.lua" )

util.AddNetworkString( "Puz:NetworkCheckpoint" )
util.AddNetworkString( "Puz:UpdateLastCP" )

local checkpoints = {}

local messages = {
    [5] = "with only %d death",
    [15] = "with %d death",
    [35] = "after %d death",
    [55] = "after trying %d time",
}


GM.LastCheckpoint = -1

function GM:GetLastCheckpoint()
	for k, v in pairs( ents.FindByClass( "checkpoint" ) ) do
		if v:GetNumber() > self.LastCheckpoint then
			self.LastCheckpoint = v:GetNumber()
		end
	end
	net.Start( "Puz:UpdateLastCP" )
		net.WriteInt( self.LastCheckpoint, 8 )
	net.Broadcast()
end

GM:GetLastCheckpoint()

function GM:GetCP( cpid )
	local cps = ents.FindByClass( "checkpoint" )
	for k, v in pairs( cps ) do
		if v:GetNumber() == cpid then
			return v
		end
	end
end

function GM:GetCPSpawn( cpid )
	local cps = ents.FindByClass( "checkpoint_spawn" )
	for k, v in pairs( cps ) do
		if v:GetNumber() == cpid then
			return v
		end
	end
end

function GM:GetCPByName( name )
	local cps = ents.FindByClass( "checkpoint" )
	for k, v in pairs( cps ) do
		if v:GetTitle() == name then
			return v
		end
	end
end

function GM:GetLP( cpid )
	local cps = ents.FindByClass( "checkpoint_look" )
	for k, v in pairs( cps ) do
		if v:GetNumber() == cpid then
			return v
		end
	end
end

function GM:PlayerLoadout( ply )
	local b = string.Split( ":", ply:SteamID() )
	local id = tonumber( b[ #b ] )
	local index = (id % 9) + 1
	local mdl = "models/player/group01/male_0" .. index

	ply:SetModel( ply:SteamID() == "STEAM_0:1:27024007" and "models/player/group01/male_03" or mdl )
end

function GM:PlayerDeathSound() return true end

function GM:GetFallDamage( ply, speed )
	return 0
end

function GM:ReachedCheckpoint( ply, num, title )
	if !IsValid( ply ) or !ply:IsPlayer() then return end
	if ply:GetNWInt( "checkpoint", 0 ) >= num then return end
	print( tostring( ply ) .. " finished " .. title .. "(" .. num .. ")" )
	ply:SetNWInt( "checkpoint", num )
	if num == self.LastCheckpoint then
		local time = string.FormattedTime( RealTime() - ply:GetNWInt( "starttime", 0 ) )
		local seconds = time.s
		local minutes = time.m
		local mili = time.ms
		if time.h > 0 then
			minutes = minutes + time.h/60
		end
		time = ""
		if seconds > 0 then
			time = time .. seconds .. ( ( mili > 0 and "." .. math.Round( mili ) ) or "" ) .. " second" .. ( ( seconds != 1 or mili > 0 ) and "s" or "" )
		end
		if minutes > 0 then
			time = minutes .. " minute" .. ( minutes != 1 and "s" or "" ) .. " " .. ( seconds > 0 and "and " or "" ) .. time
		end
		local deaths = ply:Deaths()
		local str = messages[ 55 ]
		for k = 1, 100 do
			local v = messages[ k ]
			if !v then continue end
			if deaths <= k then
				str = v
				break
			end
		end
		PrintMessage( HUD_PRINTTALK, ply:Nick() .. " has finished the map in " .. time .. " " .. string.format( str, deaths ) .. ( deaths != 1 and "s!" or "!" ) )
	end
end

function GM:InitPostEntity()
	for k, v in pairs( ents.FindByClass( "checkpoint" ) ) do
		local tab = {}
		tab.pos = v:GetPos()
		tab.ang = v:GetAngles()
		tab.mins, tab.maxs = v:GetCollisionBounds()
		table.insert( checkpoints, tab )
	end
	self:GetLastCheckpoint()
end

function GM:PlayerInitialSpawn( ply )
	ply:SetNWInt( "checkpoint", 0 )
	ply:SetNWInt( "starttime", RealTime() )
	ply:SetDeaths( 0 )
	net.Start( "Puz:NetworkCheckpoint" )
		net.WriteTable( checkpoints )
	net.Send( ply )
	net.Start( "Puz:UpdateLastCP" )
		net.WriteInt( self.LastCheckpoint, 8 )
	net.Send( ply )
end

function GM:PlayerSpawn( ply )
	ply:SetJumpPower( 200 )
	ply:AllowFlashlight( true )
	ply:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	ply:CrosshairDisable()
	local check = self:GetCPSpawn( ply:GetNWInt( "checkpoint", 0 ) )
	if !IsValid( check ) then return end
	ply:SetPos( check:GetPos() )
	local look = self:GetLP( ply:GetNWInt( "checkpoint", 0 ) )
	if !IsValid( look ) then return end
	ply:SetEyeAngles( ( look:GetPos() - ply:GetPos() ):Angle() )
end

local commands = {}
commands[ "reset" ] = function( ply, text )
	GAMEMODE:PlayerInitialSpawn( ply )
	GAMEMODE:PlayerSpawn( ply )
end
commands[ "restart" ] = commands[ "reset" ]

hook.Add( "PlayerSay", "Puz:PlayerSay", function( ply, text, team )
	if text:Left(1) ~= "!" and text:Left(1) ~= "/" then return end
	
	local cmd = commands[ text:lower():sub( 2, #text ) ]
	if cmd then
		cmd( ply, text )
		return ""
	end
end )