AddCSLuaFile( "cl_init.lua" )
IncludeCS( "shared.lua" )

util.AddNetworkString( "Puz:NetworkCheckpoint" )

local checkpoints = {}

local messages = {
    [5] = "with only %d deaths!",
    [15] = "with %d deaths!",
    [35] = "after %d deaths!",
    [55] = "after trying %d times!",
}


GM.LastCheckpoint = GM.LastCheckpoint or -1 -- autorefresh

function GM:GetLastCheckpoint()
	for k, v in pairs( ents.FindByClass( "checkpoint" ) ) do
		if v:GetNumber() > self.LastCheckpoint then
			self.LastCheckpoint = v:GetNumber()
		end
	end
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

function GM:PlayerLoadout( ply ) end

function GM:PlayerDeathSound() return true end

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
		for k = 1, 500 do
			local v = messages[ k ]
			if !v then continue end
			print( k, deaths <= k )
			if deaths <= k then
				str = v
				break
			end
		end
		PrintMessage( HUD_PRINTTALK, ply:Nick() .. " has finished the map in " .. time .. " " .. string.format( str, deaths ) )
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
	timer.Simple( 2, function()
		net.Start( "Puz:NetworkCheckpoint" )
			net.WriteTable( checkpoints )
		net.Send( ply )
	end )
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
	ply:SetEyeAngles( ( look:GetPos() - ply:GetShootPos() ):Angle() )
end