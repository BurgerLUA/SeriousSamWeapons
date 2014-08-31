
if CLIENT then

	SWEP.PrintName			= "SBC Cannon"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 1
	SWEP.ViewModelFOV		= 52
	SWEP.WepIcon			= "icons/serioussam/Cannon"
	killicon.Add("ss_cannonball", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:Deploy()
	self:SetNextPrimaryFire(CurTime() +.7)
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:IdleStuff()
	return true
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end	
	self:SetNextPrimaryFire(CurTime() +3)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_1)
	self.bInAttack = true
	self.attackStart = CurTime() +.1
	self.rdelay = CurTime() +.95
	if CLIENT then return end
	self.ChargeSound = CreateSound(self.Owner, "weapons/serioussam/cannon/Prepare.wav")
	self.ChargeSound:Play()
end

function SWEP:SpecialThink()
	if self.rdelay and CurTime() > self.rdelay then
		self:Release()
	end
	if !self.bInAttack || self.Owner:KeyDown(IN_ATTACK) || CurTime() < self.attackStart then return end
	self:Release()
end	

function SWEP:Release()
	self:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	timer.Simple(self.Primary.Delay, function() self:EmitSound("hl1/fvox/blip.wav",100,100) end)
	self.bInAttack = nil
	self.rdelay = nil
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:WeaponSound(self.Primary.Sound)
	self:TakeAmmo(1)
	self:IdleStuff()
	self:HolsterDelay()
	if CLIENT then return end
	if self.ChargeSound then self.ChargeSound:Stop() end
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector():Angle()
	local damage = math.Clamp(self.Primary.Damage *(CurTime() -(self.attackStart -.8)), self.Primary.Damage, 750)
	damage = math.Round(damage)
	pos = pos +ang:Forward() *-20 +ang:Right() *2 +ang:Up() *-2
	local ent = ents.Create("ss_cannonball")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetOwner(self.Owner)
	ent:SetExplodeDelay(5)
	ent:SetDamage(damage)
	ent:SetPhysicsAttacker(self.Owner)
	ent:Spawn()
	ent:Activate()
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		local mod = CurTime() - self.attackStart
		local vel = self.Owner:GetForward()*mod*10000
		phys:SetVelocity(vel)
	end
end

function SWEP:OnRemove()
	self.bInAttack = nil
	self.rdelay = nil
	self.attackStart = nil
	if self.ChargeSound then self.ChargeSound:Stop() end
	return true
end

function SWEP:Holster()
	if self.DisableHolster or self.bInAttack then
		return false
	end
	self:OnRemove()
	return true
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_cannon.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_cannon.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/cannon/Fire.wav")
SWEP.Primary.Damage			= 100
SWEP.Primary.Delay			= 5
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Ammo			= "Cannonball"

SWEP.EnableIdle				= false