
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "StreamURL Youtube"
ENT.Author			= "The Maw"
ENT.Information		= "Video streams a youtube video"
ENT.Category		= "Fun + Games"

ENT.Editable		= false
ENT.Spawnable		= true
ENT.AdminOnly		= false
ENT.RenderGroup		= RENDERGROUP_TRANSLUCENT

function ENT:SpawnFunction( pl, tr, class )
	if (!tr.Hit) then return end
	if (!StreamCanPlay(pl,"")) then pl:ChatPrint("You don't have streaming permissions!") return end
	
	local pos = tr.HitPos + tr.HitNormal * 30
	
	local ent = ents.Create( class )
	ent:SetPos( pos )
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:Initialize()
	if (SERVER) then
		self:SetModel( "models/props/cs_office/TV_plasma.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		self:PhysWake()
	else
		self.RadioURL = nil
		self.RadioFFT = {}
	end
end

if (CLIENT) then
	local TextColor 	= Color(255,255,255)
	
	function ENT:Think()
		/*if (IsValid(self.YoutubeURL)) then
			self.YoutubeURL:UpdateHTMLTexture()
			self.Mat = self.YoutubeURL:GetHTMLMaterial()
		end*/
	end
	
	function ENT:OnRemove()
		if (IsValid(self.YoutubeURL)) then
			self.YoutubeURL:Remove()
		end
	end
	
	function ENT:Draw()
		self:DrawModel()
		
		local Ang = self:GetAngles()
		Ang:RotateAroundAxis(Ang:Right(),-90)
		Ang:RotateAroundAxis(Ang:Up(),90)
		
		cam.Start3D2D(self:GetPos()+self:GetForward()*6.2+self:GetUp()*19,Ang,0.06)
			surface.SetDrawColor(255,255,255,255)
			surface.DrawRect(-480,-270,960,540) 
				
			if (IsValid(self.YoutubeURL)) then
				self.YoutubeURL:SetPaintedManually(false)
				self.YoutubeURL:PaintManual()
				self.YoutubeURL:SetPaintedManually(true)
			end
		cam.End3D2D()
	end
end

function ENT:Use( pl, c )
	if (IsValid(pl) and pl:IsPlayer() and StreamCanPlay(pl,"")) then
		pl:SendLua("OpenYoutubeMenu("..self:EntIndex()..")")
	end
end
