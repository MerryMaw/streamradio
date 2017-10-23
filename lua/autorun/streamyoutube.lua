

if (CLIENT) then
	local URLBar 	= nil
	
	local x 		= ScrW()/2-200
	local y 		= ScrH()/2-50
	
	hook.Add("Initialize","SY_YoutubeBars",CreateYoutubeURLBar)
	
	local function CreateYoutubeURLBar()
		if (URLBar) then URLBar:Remove() end
		
		URLBar = vgui.Create("DFrame")
		URLBar:SetPos(x,y)
		URLBar:SetSize(400,70)
		URLBar:SetTitle("Set Youtube URL")
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
			net.Start("SY_SETSTREAM")
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
			net.Start("SY_ENDSTREAM")
				net.WriteEntity(URLBar.ID)
			net.SendToServer()
			
			URLBar:SetVisible(false)
		end
		
		URLBar.Stop.Paint = function(s,w,h)
			surface.SetDrawColor( 255, 255, 255, 150 )
			surface.DrawRect(0,0,w,h)
		end
	end
	
	function OpenYoutubeMenu(ID)
		if (!IsValid(URLBar)) then CreateYoutubeURLBar() end
		URLBar:SetVisible(true)
		URLBar.ID = ents.GetByIndex(ID)
	end
	
	net.Receive("SY_UPDATE",function()
		local Ent 		= net.ReadEntity()
		local OrgURL 	= net.ReadString()
		local Time 		= net.ReadUInt(16)
		
		if (!IsValid(Ent) or !OrgURL) then return end
		
		URL = OrgURL
		
		if (URL == "") then
			if (Ent.YoutubeURL) then
				Ent.YoutubeURL:SetHTML("")
			end
			Ent.URL = OrgURL
			return 
		end
		
		--Treatment for the URL
		URL = string.gsub(URL,[[https://]],"")
		if (URL:find("www.youtube.com") != 1) then return end
		URL = string.Explode("/",URL)[2]
		if (!URL) then return end
		URL = string.Explode("&",URL)[1]
		URL = string.Explode("=",URL)[2]
		if (!URL) then return end
		URL = string.gsub(URL,"watch?v=","")
		
		
		if (!IsValid(Ent.YoutubeURL)) then
			Ent.YoutubeURL = vgui.Create("HTML")
			Ent.YoutubeURL:SetPos(-480,-270)
			Ent.YoutubeURL:SetSize(960,540)
			Ent.YoutubeURL:SetMouseInputEnabled(false)
			Ent.YoutubeURL:SetPaintedManually(true)
		end
		
		local HTML = GetHTMLScript(URL)
			
		if (!IsValid(Ent.YoutubeURL)) then MsgN("This panel appears to be destroyed into oblivion... Is one of your addons deleting the HTML panel?") return end
		Ent.YoutubeURL:SetHTML(HTML)
		Ent.URL = OrgURL
		
		Ent.YoutubeURL.Think = function(s)
			local Min,Max = StreamVideoFadeDistance(s,OrgURL)
			local dis = math.Clamp(LocalPlayer():GetShootPos():Distance(Ent:GetPos()),Min,Max)
			local m = math.Remap(dis,Max,Min,0,100)
			
			Ent.YoutubeURL:RunJavascript("player.setVolume("..m..");")
		end
	end)
else
	AddCSLuaFile()
	
	util.AddNetworkString("SY_SETSTREAM")
	util.AddNetworkString("SY_ENDSTREAM")
	util.AddNetworkString("SY_UPDATE")
	
	function UpdateYoutubeTV(ent,url)
		net.Start("SY_UPDATE")
			net.WriteEntity(ent)
			net.WriteString(url)
		net.Broadcast()
		
		if (url == "") then 
			ent.URL = nil
			ent.Time = 0
		else 
			ent.URL = url 
			ent.Time = CurTime()
		end
	end
	
	function ReloadYoutubeTV(ent,pl)
		if (ent.URL and IsValid(pl)) then
			net.Start("SY_UPDATE")
				net.WriteEntity(ent)
				net.WriteString(ent.URL)
				net.WriteUInt(math.ceil(ent.Time),16)
			net.Send(pl)
		end
	end
	
	net.Receive("SY_SETSTREAM",function(bit,pl)
		local TV 	= net.ReadEntity()
		local URL   = net.ReadString()
		
		if (!StreamCanPlay(pl,URL)) then return end
		
		UpdateYoutubeTV(TV,URL)
	end)
	
	net.Receive("SY_ENDSTREAM",function(bit,pl)
		local TV = net.ReadEntity()
		
		if (!StreamCanPlay(pl,"")) then return end
		
		UpdateYoutubeTV(TV,"")
	end)
end