
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "StreamURL Radio"
ENT.Author			= "The Maw"
ENT.Information		= "A radio version of StreamURL"
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
		self:SetModel( "models/props/cs_office/radio.mdl" )
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
	
	local DrawRect  	= surface.DrawRect
	local DrawRectRot  	= surface.DrawTexturedRectRotated
	local DrawLine  	= surface.DrawLine
	local SetDrawColor	= surface.SetDrawColor
	
	local rad 	= math.rad
	local cos 	= math.cos
	local sin 	= math.sin
	local ceil 	= math.ceil
	local floor = math.floor
	
	function ENT:Think()
		if (IsValid(self.RadioURL)) then
			self.RadioURL:SetPos(self:GetPos())
			self.RadioURL:FFT(self.RadioFFT,FFT_256)
		end
	end
	
	function ENT:OnRemove()
		if (IsValid(self.RadioURL)) then
			self.RadioURL:Stop()
		end
	end
	
	function ENT:Draw()
		self:DrawModel()
		
		local Ang = self:GetAngles()
		Ang:RotateAroundAxis(Ang:Right(),-90)
		Ang:RotateAroundAxis(Ang:Up(),90)
		
		cam.Start3D2D(self:GetPos()-Ang:Right()*10,Ang,0.1)
			if (IsValid(self.RadioURL) and self.RadioFFT) then
				local C = HSVToColor(cos(rad(CurTime()*300))*180,1,1)
				local N = self.RadioURL:GetFileName()
				local L = N:len()
				
				local Clock = UnPredictedCurTime()*4
				local Tip   = math.Clamp(ceil(Clock)-floor(Clock/L)*L,0,L-25)
				
				SetDrawColor(C.r,C.g,C.b,255)
				draw.NoTexture()
				
				local OffHeight = -40
				
				for k,v in pairs(self.RadioFFT) do
					local H = v*200
					
					if (H >= 0.5) then
						local A = 90+90*(k/128)
						local R = rad(-A)
						
						local X = cos(R)*128
						local Y = sin(R)*128
						
						DrawRectRot( X, OffHeight+Y, H, 1, A )
						DrawRectRot( -X, OffHeight+Y, H, 1, -A )
					end
				end
				
				SetDrawColor( 0, 0, 0, 100 )
				DrawRect( -126, -40, 256, 20)
				draw.SimpleText( N:sub(Tip,Tip+25), "ChatFont", 0, -30, TextColor, 1, 1 )
			else
				SetDrawColor( 0, 0, 0, 100 )
				DrawRect( -126, -40, 256, 20)
				draw.SimpleText( "No streams active!", "ChatFont", 0, -30, TextColor, 1, 1 )
			end
		cam.End3D2D()
	end
end

function ENT:Use( pl, c )
	if (IsValid(pl) and pl:IsPlayer() and StreamCanPlay(pl,"")) then
		pl:SendLua("OpenRadioMenu("..self:EntIndex()..")")
	end
end
