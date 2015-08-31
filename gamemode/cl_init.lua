include( "shared.lua" )

local ply = LocalPlayer() -- here for script refreshes
local checkpoints = {}

net.Receive( "Puz:NetworkCheckpoint", function()
	checkpoints = net.ReadTable()
	print( "recieved" )
end )

hook.Add( "InitPostEntity", "PASS:LocalPlayer", function()
	ply = LocalPlayer()
end )

function GM:PostDrawOpaqueRenderables()
	for k, v in pairs( checkpoints ) do
		render.DrawWireframeBox( v.pos, v.ang, v.mins, v.maxs, Color( 255, 99, 71 ), true )
	end
end