
if CLIENT then

	SWEP.PrintName			= "CSS AUG"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.WepIcon			= "icons/serioussam/Colt"
	killicon.AddFont( "weapon_cs_aug", "csd", "e", Color(255, 100, 100, 100) )
	SWEP.ViewModelFlip = true
	
end 
function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	
	if self:GetNWBool("zoomed",false) == true then
		self.Primary.Cone			= 0.001
		self.Primary.RecoilMul	= 0.25
	else
		self.Primary.Cone			= .1
		self.Primary.RecoilMul	= 1
	end
	
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:Attack()
	self:SeriousFlash()
	self:IdleStuff()
end

function SWEP:SecondaryAttack()
	self:EmitSound("weapons/zoom.wav",100,100)
	if CLIENT then return end
	
	local delay = 0.3
	
	if not self.ScopeDelay then
		self.ScopeDelay = 0
	end
	
	if self.ScopeDelay > CurTime() then return end
	
	self.ScopeDelay = delay + CurTime()
	
	if not self.ScopeMode then
		self.ScopeMode = 0
	end
	

	
	if self.ScopeMode == 1 then
		self.ScopeMode = 0
		self.Owner:SetFOV(75,delay)
		self:SetNWBool("zoomed",false)
	elseif self.ScopeMode == 0 then
		self.ScopeMode = 1
		self.Owner:SetFOV(20,delay)
		self:SetNWBool("zoomed",true)
	end
end


function SWEP:DrawHUD()
	if self:GetNWBool("zoomed",false) == false then return end
	local x,y = ScrW(), ScrH()
	


	surface.SetMaterial(Material("sprites/scope_arc"))
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRectRotated(ScrW()/2+ScrH()/4, ScrH()/2+ScrH()/4, ScrH()/2, ScrH()/2,0)
	surface.DrawTexturedRectRotated(ScrW()/2-ScrH()/4, ScrH()/2-ScrH()/4, ScrH()/2, ScrH()/2,180)
	surface.DrawTexturedRectRotated(ScrW()/2+ScrH()/4, ScrH()/2-ScrH()/4, ScrH()/2, ScrH()/2,90)
	surface.DrawTexturedRectRotated(ScrW()/2-ScrH()/4, ScrH()/2+ScrH()/4, ScrH()/2, ScrH()/2,270)
	
	
	surface.SetMaterial(Material("vgui/gfx/vgui/solid_background"))
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0,0,ScrW()*0.11,ScrH())
	
	surface.SetMaterial(Material("vgui/gfx/vgui/solid_background"))
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(ScrW()*0.89,0,ScrW()*0.12,ScrH())

end

function SWEP:AdjustMouseSensitivity()
	if self:GetNWBool("zoomed",false) == true then
		sen = 0.5
	else
		sen = 1
	end	
	
	return sen
end
	

function SWEP:Attack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)	
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:WeaponSound(self.Primary.Sound)
	self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone)
	if !self.Owner:IsNPC() then self:TakePrimaryAmmo(1) end
	self.NextReload = CurTime() +self.Primary.Delay + 0.1
	self:HolsterDelay()
end

function SWEP:SpecialThink()
	if self.NextReload and CurTime() > self.NextReload then
		self.NextReload = nil
	end
end

function SWEP:Reload()
	if self:Clip1() > 0 and self.NextReload then return end
	if self:Clip1() >= self.Primary.ClipSize then return end
	self.DisableHolster = CurTime() + 1
	self:SendWeaponAnim(ACT_VM_RELOAD)
	self:SetNWBool("zoomed",false)
	self.Owner:SetAnimation(PLAYER_RELOAD)
	self:SetClip1(self.Primary.ClipSize)
		if SERVER then
		self.Owner:SetFOV(75,0.3)
	end
	self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	self:IdleStuff()
end

function SWEP:CanPrimaryAttack()
	if self:Clip1() <= 0 then
		--self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
		self:Reload()
		return false
	end 
	return true
end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Counter-Strike Source Weapons"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/v_rif_aug.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_aug.mdl"

SWEP.Primary.Damage			= 31
SWEP.Primary.Sound			= Sound("weapons/aug/aug-1.wav")
SWEP.Primary.Cone			= .1
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 60
SWEP.Primary.Delay			= .12
--SWEP.Primary.Ammo			= "smg1"
SWEP.Primary.RecoilMul	= 1

SWEP.ReloadSound			= ""