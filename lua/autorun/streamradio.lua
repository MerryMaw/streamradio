
--Lets do a bunch of menu working here...
if (CLIENT) then
	local URLBar 	= nil
	
	local x 		= ScrW()/2-200
	local y 		= ScrH()/2-50
	
	hook.Add("Initialize","SR_RadioBars",function()
		URLBar = vgui.Create("DFrame")
		URLBar:SetPos(x,y)
		URLBar:SetSize(400,70)
		URLBar:SetTitle("Set Radio URL")
		URLBar:SetVisible(false)
		URLBar:ShowCloseButton(true)
		URLBar:SetDeleteOnClose(false)
		URLBar:MakePopup()
		URLBar.ID = NULL
		URLBar.Paint = function(s,w,h)
			surface.SetDrawColor( 30, 60, 90, 230 )
			surface.DrawRect(0,0,w,h)
		end
		
		URLBar.Typer = vgui.Create("DTextEntry",URLBar)
		URLBar.Typer:SetPos(5,20)
		URLBar.Typer:SetSize(390,20)
		URLBar.Typer:SetText("")
		URLBar.Typer.OnEnter = function(s) 
			net.Start("SR_SETSTREAM")
				net.WriteEntity(URLBar.ID)
				net.WriteString(s:GetValue())
			net.SendToServer()
			
			URLBar:SetVisible(false)
		end
		
		URLBar.Stop = vgui.Create("DButton",URLBar)
		URLBar.Stop:SetText("Stop")
		URLBar.Stop:SetPos(5,45)
		URLBar.Stop:SetSize(390,20)
		URLBar.Stop.DoClick = function(s) 
			net.Start("SR_ENDSTREAM")
				net.WriteEntity(URLBar.ID)
			net.SendToServer()
			
			URLBar:SetVisible(false)
		end
		
		URLBar.Stop.Paint = function(s,w,h)
			surface.SetDrawColor( 255, 255, 255, 150 )
			surface.DrawRect(0,0,w,h)
		end
	end)
	
	function OpenRadioMenu(ID)
		URLBar:SetVisible(true)
		URLBar.ID = ents.GetByIndex(ID)
	end
	
	net.Receive("SR_UPDATE",function()
		local Ent = net.ReadEntity()
		local URL = net.ReadString()
		
		if (!IsValid(Ent)) then return end
		
		if (URL == "" and IsValid(Ent.RadioURL)) then Ent.RadioURL:Stop() Ent.RadioURL = nil return end
		
		sound.PlayURL( URL, "3d mono noplay", function( chan )
			if (IsValid(Ent) and IsValid(chan)) then 
				if (IsValid(Ent.RadioURL)) then Ent.RadioURL:Stop() end
				Ent.RadioURL = chan
				
				chan:Set3DFadeDistance(200,40000)
				chan:Play()
			end
		end)
	end)
else
	AddCSLuaFile()
	
	util.AddNetworkString("SR_SETSTREAM")
	util.AddNetworkString("SR_ENDSTREAM")
	util.AddNetworkString("SR_UPDATE")
	
	function UpdateStreamRadio(ent,url)
		net.Start("SR_UPDATE")
			net.WriteEntity(ent)
			net.WriteString(url)
		net.Broadcast()
		
		if (url == "") then ent.URL = nil
		else ent.URL = url end
	end
	
	function ReloadStreamRadio(ent,pl)
		if (ent.URL and IsValid(pl)) then
			net.Start("SR_UPDATE")
				net.WriteEntity(ent)
				net.WriteString(ent.URL)
			net.Send(pl)
		end
	end
	
	net.Receive("SR_SETSTREAM",function(bit,pl)
		local Radio = net.ReadEntity()
		local URL   = net.ReadString()
		
		if (!StreamCanPlay(pl,URL)) then return end
		
		UpdateStreamRadio(Radio,URL)
	end)
	
	net.Receive("SR_ENDSTREAM",function(bit,pl)
		local Radio = net.ReadEntity()
		
		if (!StreamCanPlay(pl,"")) then return end
		
		UpdateStreamRadio(Radio,"")
	end)
end