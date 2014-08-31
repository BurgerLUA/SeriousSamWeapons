
if CLIENT then

	SWEP.PrintName			= "XM-214-A Minigun"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.ViewModelFOV		= 68
	SWEP.WepIcon			= "icons/serioussam/MiniGun"
	killicon.Add("weapon_ss_minigun", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	util.PrecacheSound(self.Primary.Sound)
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime() +.45)
	return true
end

function SWEP:PrimarySoundStart()
	if !self.PSound then
		if SERVER then
			self.LoopSound = CreateSound(self.Owner, "weapons/serioussam/minigun/Rotate.wav")
			self.LoopSound:Play()
		end
	end
	self.PSound = true
end

local AnimDelay = CurTime()
local Click = "Weapon_Sam_MiniGun.Click"

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	
	if !self.InAttack then		
		self:EmitSound("Weapon_Sam_MiniGun.RotateUp")
		self:EmitSound(Click)
		self.AttackDelay = CurTime() + 0.75
		self:SendWeaponAnim(ACT_VM_PULLPIN)
	end
	self.InAttack = true
	
	if self.AttackDelay then
		if CurTime() < self.AttackDelay then return end
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self:PrimarySoundStart()
		self:WeaponSound(self.Primary.Sound)
		self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone)
		self:SeriousFlash()
		self:TakeAmmo(self.AmmoToTake)
		self:IdleStuff()
		self:HolsterDelay()
		self.EndSmoke = true
		self.SmokeAmount = self.SmokeAmount + 1
		
		if AnimDelay <= CurTime() then	
			local delay
			//i hate mp
			if game.SinglePlayer() then
				delay = .71
			else
				delay = .1
			end
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			AnimDelay = CurTime() +delay
		end
	end
end

function SWEP:Think()
	if self.DisableHolster and CurTime() > self.DisableHolster then
		self.DisableHolster = nil
	end

	if self.Owner:KeyReleased(IN_ATTACK) or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
		if self.EndSmoke then
			self:Smoke()
			self:ManySmoke()
		end
		if self.InAttack then
			if game.SinglePlayer() then
				if SERVER then self:EmitSound("Weapon_Sam_MiniGun.RotateDown") self:EmitSound(Click) end
			else
				self:EmitSound("Weapon_Sam_MiniGun.RotateDown")
				self:EmitSound(Click)
			end
		end
		self:OnRemove()
	end
end

function SWEP:OnRemove()
	if SERVER then
		if self.LoopSound then self.LoopSound:Stop() end
	end
	self.InAttack = nil
	self.AttackDelay = nil
	self.PSound = nil
	self.EndSmoke = nil
	self.SmokeAmount = 0
end

function SWEP:Holster()
	if self.DisableHolster or self.InAttack then
		return false
	end
	self:OnRemove()
	return true
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_minigun.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_minigun.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/minigun/Fire.wav")
SWEP.Primary.Damage			= 3
SWEP.Primary.NumShots		= 2
SWEP.Primary.Cone			= .03
SWEP.Primary.Delay			= .05
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Ammo			= "smg1"

SWEP.MuzzleScale			= 18

SWEP.EnableIdle				= true
SWEP.SmokeAmount			= 0