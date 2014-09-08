
if CLIENT then

	SWEP.PrintName			= "Double Barrel Coach Gun"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 1
	SWEP.ViewModelFOV		= 52
	SWEP.WepIcon			= "icons/serioussam/DoubleShotgun"
	killicon.Add("weapon_ss_doubleshotgun", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:SpecialThink()
	if self.ReloadSoundDelay and CurTime() > self.ReloadSoundDelay then
		self.ReloadSoundDelay = nil
		self:EmitSound(self.ReloadSound)
	end
end

function SWEP:HolsterDelay()
	self.ReloadSoundDelay = CurTime() +.3
	self.DisableHolster = CurTime() +self.Primary.Delay -.3
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_doubleshotgun.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_doubleshotgun.mdl"


SWEP.Primary.Sound			= Sound("weapons/serioussam/doubleshotgun/Fire.wav")
SWEP.Primary.Damage			= 105/12
SWEP.Primary.NumShots		= 24
SWEP.Primary.Cone			= .16
SWEP.Primary.Delay			= 1.35
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.Ammo			= "Buckshot"

SWEP.AmmoToTake				= 2

SWEP.ReloadSound			= Sound("weapons/serioussam/doubleshotgun/Reload.wav")

SWEP.MuzzleScale			= 32
SWEP.EnableSmoke			= true