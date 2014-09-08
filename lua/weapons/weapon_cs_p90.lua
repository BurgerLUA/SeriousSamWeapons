
if CLIENT then

	SWEP.PrintName			= "CSS P90"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.WepIcon			= "icons/serioussam/Colt"
	killicon.AddFont( "weapon_cs_p90", "csd", "m", Color(255, 100, 100, 100) )
	SWEP.ViewModelFlip = true

end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:Attack()
	self:SeriousFlash()
	self:IdleStuff()
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
	self.Owner:SetAnimation(PLAYER_RELOAD)
	self:SetClip1(self.Primary.ClipSize)
	self:EmitSound(self.ReloadSound)
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

SWEP.HoldType			= "smg"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Counter-Strike Source Weapons"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/v_smg_p90.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_p90.mdl"

SWEP.Primary.Damage			= 25
SWEP.Primary.Sound			= Sound("weapons/p90/p90-1.wav")
SWEP.Primary.Cone			= .01
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 50
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Delay			= .1
--SWEP.Primary.Ammo			= "smg1"
SWEP.Primary.RecoilMul	= 1

SWEP.ReloadSound			= ""