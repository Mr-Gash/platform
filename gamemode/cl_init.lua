include( "shared.lua" )

local ply = LocalPlayer() -- here for script refreshes
hook.Add( "InitPostEntity", "Puz:LocalPlayer", function() ply = LocalPlayer() end )

local checkpoints = {}

GM.LastCheckpoint = -1

net.Receive( "Puz:NetworkCheckpoint", function()
	checkpoints = net.ReadTable()
end )

net.Receive( "Puz:UpdateLastCP", function()
	GAMEMODE.LastCheckpoint = net.ReadInt( 8 )
end )

function GM:PostDrawOpaqueRenderables()
	for k, v in pairs( checkpoints ) do
		render.DrawWireframeBox( v.pos, v.ang, v.mins, v.maxs, Color( 255, 99, 71 ), true )
	end
end

local scrw, scrh = ScrW(), ScrH()
local myw, myh = 1920, 1080
local function ScaleX( x )
	return math.Round( x * ( scrw/myw ) )
end
local function ScaleY( y )
	return math.Round( y * ( scrh/myh ) )
end

function GM:HUDShouldDraw( name )
	if name == "CHudHealth" then return false end
	return true
end

local lastval = 0
local easing

function GM:HUDPaint()
	if !easing and lastval != ply:GetNWInt( "checkpoint", 0 ) then
		easing = 0
	end
	local x, y = ScaleX( 50 ), ScaleY( 900 )
	local w, h = ScaleX( 300 ), ScaleY( 60 )
	surface.SetDrawColor( Color( 65, 65, 65 ) )
	surface.DrawRect( x, y, w, h )
	surface.SetDrawColor( Color( 150, 150, 150 ) )
	surface.DrawRect( x + 5, y + 5, w - 10, h - 10 )
	surface.SetDrawColor( Color( 100, 100, 255 ) )
	local w = math.ceil( ( w - 10 ) * lastval / GAMEMODE.LastCheckpoint ) -- ( ~300 - 10 ) * previous checkpoint number / amount of checkpoints
	if easing then
		--print( ( w * math.ceil( ply:GetNWInt( "checkpoint", 0 ) / GAMEMODE.LastCheckpoint ) - w ) )
		local diff = math.ceil( ( ScaleX( 300 ) - 10 ) * ply:GetNWInt( "checkpoint", 0 ) /  GAMEMODE.LastCheckpoint ) - w -- ( ~300 - 10 ) * current checkpoint number / amount of checkpoints - width of bar at previous checkpoint
		w = w + diff * math.EaseInOut( easing, 0, .8 ) -- width plus diff * float between 0 and 1
		easing = easing + .6 * FrameTime()
		if easing >= 1 then
			easing = nil
			lastval = ply:GetNWInt( "checkpoint", 0 )
		end
	end
	surface.DrawRect( x + 5, y + 5, w, h - 10 )
end