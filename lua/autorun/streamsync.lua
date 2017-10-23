
local simple 	= timer.Simple
	
if (SERVER) then
	AddCSLuaFile()
	
	util.AddNetworkString("StreamURL_Sync")
	
	net.Receive("StreamURL_Sync",function(siz,pl)
		local ent = net.ReadEntity()
		
		if (!IsValid(ent)) then return end
		
		if (ent:IsPlayer()) then 
			ent:UpdateStream(pl)
		elseif (ent:GetClass():lower() == "streamurl_radio") then
			ReloadStreamRadio(ent,pl)
		elseif (ent:GetClass():lower() == "streamurl_youtube") then
			ReloadYoutubeTV(ent,pl)
		end
	end)
else
	local Q = 0
	
	local Rand 		= math.Rand
	local simpl		= timer.Simple
	
	hook.Add("NetworkEntityCreated","StreamURL_Sync",function(ent)
		if (ent:IsPlayer() or 
			ent:GetClass() == "streamurl_radio" or 
			ent:GetClass() == "streamurl_youtube") then

			Q=Q+1
			simple(Rand(0.1,0.2)*Q,function()
			
				net.Start("StreamURL_Sync") 
					net.WriteEntity(ent)
				net.SendToServer()
				
				Q=Q-1
			end)
		end
	end)
end
