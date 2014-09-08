
if CLIENT then

	SWEP.PrintName			= "M1-A2 Thompson"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.ViewModelFOV		= 52
	SWEP.WepIcon			= "icons/serioussam/TommyGun"
	killicon.Add("weapon_ss_tommygun", SWEP.WepIcon, Color(255, 255, 255, 255))
	
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
	self:TakeAmmo(self.AmmoToTake)
	self:HolsterDelay()
	self.EndSmoke = true
	self.SmokeAmount = self.SmokeAmount + 1
end


function SWEP:SpecialThink()
	if self.Owner:KeyReleased(IN_ATTACK) or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
		if self.EndSmoke then
			self:Smoke()
			self:ManySmoke()
		end
	end
end

function SWEP:OnRemove()
	self.EndSmoke = nil
	self.SmokeAmount = 0
end

function SWEP:Holster()
	if self.DisableHolster then
		return false
	end
	self:OnRemove()
	return true
end

SWEP.HoldType			= "smg"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_tommygun.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_tommygun.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/tommygun/Fire.wav")
SWEP.Primary.Damage			= 32
SWEP.Primary.Cone			= .015
SWEP.Primary.Delay			= .08
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Ammo			= "smg1"


SWEP.MuzzleScale			= 12
SWEP.SmokeAmount			= 0