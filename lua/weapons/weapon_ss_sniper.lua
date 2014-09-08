
if CLIENT then

	SWEP.PrintName			= "Sniper Rifle"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.ViewModelFOV		= 24
	SWEP.WepIcon			= "icons/serioussam/Sniper"
	killicon.Add("weapon_ss_sniper", SWEP.WepIcon, Color(255, 255, 255, 255))
	
	surface.CreateFont("SSsniperfont", {
		font = "default",
		size = 24,
		weight = 0,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = true,
		additive = false,
		outline = false
	})

end

function SWEP:DrawHUD()
	local x, y = ScrW() / 2, ScrH() / 2
	local x1 = x -128
	
	if self:GetNetworkedBool("zoom") then
		surface.SetTexture(surface.GetTextureID("vgui/serioussam/SniperMask"))
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRectUV(128, 0, x1, y, 0, 0, -1.006, 1)
		surface.DrawTexturedRectUV(x, 0, x1, y, 0, 0, 1, 1)
		surface.DrawTexturedRectUV(128, y, x1, y, 0, 0, -1.006, -1)
		surface.DrawTexturedRectUV(x, y, x1, y, 0, 0, 1, -1)
		
		surface.SetTexture(surface.GetTextureID("vgui/serioussam/SniperWheel"))
		surface.SetDrawColor(190, 230, 255, 70)
		surface.DrawTexturedRectRotated(x, y, 170, 170, self.Owner:GetFOV() *1.5)
		
		surface.SetTexture(surface.GetTextureID("vgui/serioussam/SniperLed"))
		local r = 0
		local g = 255
		
		if self:GetNWBool("led") then
			r = 255
			g = 180
		end

		surface.SetDrawColor(r, g, 0, 255)
		surface.DrawTexturedRect(x -94, y +62, 32, 32)
		
		local arrowx = x *0.445
		local eyex = x *1.51
		surface.SetTexture(surface.GetTextureID("vgui/serioussam/SniperArrow"))
		surface.SetDrawColor(255, 220, 0, 180)
		surface.DrawTexturedRect(arrowx, y -34, 34, 34)
		surface.SetTexture(surface.GetTextureID("vgui/serioussam/SniperEye"))
		surface.DrawTexturedRect(eyex, y -38, 34, 34)
		
		draw.SimpleText(math.Round(self.Owner:GetPos():Distance(self.Owner:GetEyeTraceNoCursor().HitPos) /12), "SSsniperfont", arrowx, y +10, Color(150,180,255,200), TEXT_ALIGN_LEFT)
		draw.SimpleText(math.Round(-self.Owner:GetFOV() / 11 +9).."x", "SSsniperfont", eyex, y +10, Color(150,180,255,200), TEXT_ALIGN_LEFT)
		
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, x/4.9, ScrH())
		surface.DrawRect(ScrW() /1.111, 0, x/4.9, ScrH())
	else
		self:Crosshair()
	end
end

function SWEP:PrimaryAttack()	
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if !self:GetNetworkedBool("zoom") then self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) end
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:WeaponSound(self.Primary.Sound)
	
	local cone = self.Primary.Cone
	if self:GetNetworkedBool("zoom") then
		cone = 0.001
	else
		cone = 0.1
	end
	
	self:ShootBullet(self.Primary.Damage, self.Primary.NumShots,cone)
	self:SeriousFlash()
	self:TakeAmmo(self.AmmoToTake)
	self:IdleStuff()
	self:HolsterDelay()
	
	self:SetNWBool("led", true)
	self.LedColor = CurTime() +self.Primary.Delay -.1
end

function SWEP:OnRemove()
	self:SetNetworkedBool("zoom", false)
	self:SetVar("zoomStart", nil)
	if self.ZoomSound then self.ZoomSound:Stop() end
end

function SWEP:Holster()
	if self.DisableHolster then
		return false
	end
	self:OnRemove()
	return true
end

function SWEP:SecondaryAttack()
	if !self:GetNetworkedBool("zoom") then

		self:SetNWBool("zoom",true)
		if SERVER then
			self.Owner:DrawViewModel(false)
			self.ZoomSound = CreateSound(self.Owner, self.Primary.Special1)
			self.ZoomSound:Play()
		end
		if self:GetVar("zoomStart") != nil then return end
		self:SetVar("zoomStart", CurTime())

	else
 
		self:SetNWBool("zoom",false)
		if SERVER then
			self.Owner:SetFOV(0, 0)
			self.Owner:DrawViewModel(true)
		end
	end	
end

function SWEP:SpecialThink()
	local zoomStart = self:GetVar("zoomStart")

	if zoomStart != nil then

		self.zoomTime = math.Clamp(math.min(1-(CurTime() - zoomStart), 1),0.1,1)
		if self.zoomTime >= .1 then
		
			if self.zoomTime <= .1 then 
				if self.ZoomSound then self.ZoomSound:Stop() end
			end

			local autoRelease = self:GetVar("autoRelease")
			if (autoRelease != nil) or (not self.Owner:KeyDown(IN_ATTACK2)) then
				self:SetVar("zoomStart", nil)

				if autoRelease != nil then
					self:SetVar("autoRelease", nil)
				end
				if self.ZoomSound then self.ZoomSound:Stop() end
			end

		elseif self.Owner:KeyReleased(IN_ATTACK2) then
			self:SetVar("autoRelease", true)
		end
	end
	
	if self.Owner:KeyDown(IN_ATTACK2) then
		if !self:GetNetworkedBool("zoom") then return end
		if SERVER then 
			self.Owner:SetFOV(self.zoomTime * 90, 0) 
		end
	end
	
	if self.LedColor and CurTime() > self.LedColor then
		self.LedColor = nil
		self:SetNWBool("led", false)
	end
end

function SWEP:AdjustMouseSensitivity()
	if self:GetNetworkedBool("zoom") then
		return self.Owner:GetFOV() /90
	end
end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_sniper.mdl"
SWEP.WorldModel			= "models/weapons/w_snip_awp.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/sniper/Fire.wav")
SWEP.Primary.Special1		= Sound("weapons/serioussam/sniper/Zoom.wav")
SWEP.Primary.Damage			= 120
SWEP.Primary.Cone			= 0.1
SWEP.Primary.Delay			= 1.4
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.Ammo			= "SniperRound"
SWEP.Primary.RecoilMul	= 0.25

SWEP.Secondary.Automatic	= false

SWEP.MuzzleScale			= 26
SWEP.EnableSmoke			= true

SWEP.SBobScale				= .6