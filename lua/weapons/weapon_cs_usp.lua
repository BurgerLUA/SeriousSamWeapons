
if CLIENT then

	SWEP.PrintName			= "(WIP) CSS USP"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.WepIcon			= "icons/serioussam/Colt"
	killicon.AddFont( "weapon_cs_usp", "csd", "y", Color(255, 100, 100, 100) )
	SWEP.ViewModelFlip = true
	
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	if self.AttachDelay > CurTime() then return end
	
	
	if self.FireMode == 1 then
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	else
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_SILENCED)
	end
	
	self.FireDelay = 2 + CurTime()
	
	self:Attack()
	self:SeriousFlash()
	--self:IdleStuff()
end

function SWEP:SecondaryAttack()

	if self.AttachDelay > CurTime() then return end
	
	self.AttachDelay = CurTime() + 3
	
	if self.FireMode == 1 then
		self:SendWeaponAnim(ACT_VM_ATTACH_SILENCER)
		self.Primary.Sound = Sound("weapons/usp/usp1.wav")
		self.Primary.Damage	= 32
		self.FireMode = 2
	else
		self:SendWeaponAnim(ACT_VM_DETACH_SILENCER)
		self.Primary.Sound = Sound("weapons/usp/usp_unsil-1.wav")
		self.Primary.Damage	= 32*0.9
		self.FireMode = 1
	end
	
	
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
	--[[
	if self:CanPrimaryAttack() and self.AttachDelay < CurTime() and self.FireDelay < CurTime() and self.ReloadDelay < CurTime() then
		if self.FireMode == 1 then
			self:SendWeaponAnim(ACT_VM_IDLE)
		else
			self:SendWeaponAnim(ACT_VM_IDLE_SILENCED)
		end
	end
	--]]
end

function SWEP:Reload()
	if self:Clip1() > 0 and self.NextReload then return end
	if self:Clip1() >= self.Primary.ClipSize then return end
	self.DisableHolster = CurTime() + 1
	
	if self.FireMode == 1 then
		self:SendWeaponAnim(ACT_VM_RELOAD)
	else
		self:SendWeaponAnim(ACT_VM_RELOAD_SILENCED)
	end
	
	
	
	
	self.Owner:SetAnimation(PLAYER_RELOAD)
	self:SetClip1(self.Primary.ClipSize)
	self:EmitSound(self.ReloadSound)
	self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	self.ReloadDelay = CurTime() + self.Owner:GetViewModel():SequenceDuration()

	--self:IdleStuff()
end

function SWEP:CanPrimaryAttack()
	if self:Clip1() <= 0 then
		self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
		self.ReloadDelay = CurTime() + self.Owner:GetViewModel():SequenceDuration()
		self:Reload()
		return false
	end 
	return true
end




SWEP.HoldType			= "pistol"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Counter-Strike Source Weapons"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/v_pist_usp.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_usp.mdl"

SWEP.Primary.Damage			= 32
SWEP.Primary.Sound			= Sound("weapons/usp/usp_unsil-1.wav")
SWEP.Primary.Cone			= .01
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 12
SWEP.Primary.DefaultClip	= 60
SWEP.Primary.Delay			= .01
--SWEP.Primary.Ammo			= "smg1"
SWEP.Primary.RecoilMul	= 1
SWEP.Primary.Automatic = false

SWEP.ReloadSound			= ""

SWEP.FireMode = 1
SWEP.AttachDelay = 0
SWEP.FireDelay = 0
SWEP.ReloadDelay = 0
