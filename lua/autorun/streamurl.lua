
/*
	Simple StreamURL
	    By The Maw
*/

local meta 		= FindMetaTable("Player")

local simple 	= timer.Simple
local Tremove	= table.remove
local random	= math.random

--OVERRIDE!
--Determines wether a player can stream or not.
if (!StreamCanPlay) then 
	function StreamCanPlay(pl,url) 
		return pl:IsAdmin() 
	end
end

--Determines the volume of the audio streaming (TV is video streaming)
if (!StreamVolume) then 
	function StreamVolume(pl,url) 
		return 1 
	end
end

--Determines the fading distance of the audio streaming (TV is video streaming)
if (!StreamFadeDistance) then 
	function StreamFadeDistance(pl,url) 
		return 200,1000 
	end
end

--Determines the fading distance of the video streaming (TV is video streaming)
if (!StreamVideoFadeDistance) then 
	function StreamVideoFadeDistance(ent,url) 
		return 100,700 
	end
end
--End

if (SERVER) then
	AddCSLuaFile()

	util.AddNetworkString("STREAM")
	util.AddNetworkString("ENDSTREAM")
	
	concommand.Add("StreamURL",function(pl,com,args)
		if (!IsValid(pl)) then return end
		pl:StreamSong(table.concat(args," "))
	end)
	
	concommand.Add("EndStream",function(pl,com,args)
		if (!IsValid(pl)) then return end
		pl:EndStream()
	end)
	
	function meta:StreamSong(URL)
		if (!StreamCanPlay(self,URL)) then return end
		
		self.URL = URL
		
		net.Start("STREAM")
			net.WriteEntity(self)
			net.WriteString(URL)
		net.Broadcast()
	end
	
	function meta:EndStream()
		self.URL = nil
		
		net.Start("ENDSTREAM")
			net.WriteEntity(self)
		net.Broadcast()
	end
	
	function meta:UpdateStream(pl)
		if (self.URL and IsValid(pl)) then
			net.Start("STREAM")
				net.WriteEntity(self)
				net.WriteString(self.URL)
			net.Send(pl)
		end
	end
	
	hook.Add("PlayerInitialSpawn","SyncPlayerStreams",function(pl) pl:UpdateStream() end)
else
	local Emitter 	= ParticleEmitter( Vector(0,0,0) )
	local Up		= Vector(0,0,20)
	local Retries	= 0
	local Streams 	= {}
	
	function TryURL(url,pl)
		if (!IsValid(pl)) then return end
		
		
		if (Retries < 4) then
			local ID 	= pl:UniqueID()
			local Tags 	= "noplay"
			
			if (pl != LocalPlayer()) then Tags = "3d mono noplay" end
			
			sound.PlayURL( url, Tags, function( chan )
				if (!IsValid(pl)) then return end
				
				if (!chan) then 
					TryURL(url,pl) 
					Retries = Retries+1
					return
				end
				
				if (Streams[ID]) then Streams[ID]:Stop() end
				
				chan:Play() 
				chan:SetVolume(StreamVolume(pl,url))
				chan:Set3DFadeDistance(StreamFadeDistance(pl,url))
				
				Streams[ID] = chan 
				Retries = 0 
			end)
		else
			Retries = 0
			Msg("Couldn't play "..url.." \n")
		end
	end
	
	net.Receive("STREAM",function()
		local pl = net.ReadEntity()
		local URL = net.ReadString()
		
		if (!IsValid(pl)) then return end
		
		TryURL(URL,pl)
	end)
	
	net.Receive("ENDSTREAM",function()
		local pl = net.ReadEntity()
		
		if (!IsValid(pl)) then return end
		
		local ID = pl:UniqueID()
		if (Streams[ID]) then Streams[ID]:Stop() Streams[ID] = nil end
	end)
		
	hook.Add("Think","Streamer",function()
		for k,st in pairs(Streams) do
			if (!st) then Tremove(Streams,k)
			else
				local v = player.GetByUniqueID(k)
				
				if (!IsValid(v)) then 
					st:Stop() 
					Tremove(Streams,k)
				else
					local Pos = v:GetShootPos()
					
					if (!v.PTime or v.PTime < CurTime()) then
						local particle = Emitter:Add( "particles/balloon_bit", Pos + VectorRand()*15)
						particle:SetDieTime( 1 )
						particle:SetVelocity( Up )
						
						particle:SetStartAlpha( 250 )
						particle:SetEndAlpha( 0 )
						
						particle:SetStartSize( 2 )
						particle:SetEndSize( 2 )
						
						particle:SetColor( random( 0, 250 ), random( 0, 250 ), random( 0, 250 ) )
						
						v.PTime = CurTime()+0.1
					end
					
					st:SetPos(Pos)
				end
			end
		end
	end)
end