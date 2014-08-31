
if CLIENT then

	SWEP.PrintName			= "XL2 Lasergun"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.ViewModelFOV		= 70
	SWEP.WepIcon			= "icons/serioussam/Laser"
	killicon.Add("weapon_ss_laser", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	
	if !self.Attack then
		self.First = true
	end
	self.Attack = true
	
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:WeaponSound(self.Primary.Sound)
	self:TakeAmmo(1)	
	
	
	local dmg = self.Primary.Damage
	local numbul = 1
	
	
	local Kick = -(dmg*numbul/20)/2*self.Primary.RecoilMul

	if CLIENT or game.SinglePlayer() then
		timer.Simple(0.01,function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then return end
			self.Owner:SetEyeAngles( self.Owner:EyeAngles() + Angle(Kick,Kick*math.Rand(-1,1)*0.5,0)*2 )
		end)
	end
	
	self.Owner:ViewPunch(Angle(Kick,Kick*math.Rand(-1,1)*0.5,0))
	
	
	if SERVER then
		local pos = self.Owner:GetShootPos()
		local ang = self.Owner:GetAimVector():Angle()
		
		if self.First then
			self.First = nil
			self.Second = true
			pos = pos +ang:Up() *-7
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_1)
		elseif self.Second then
			self.Second = nil
			self.First = nil
			self.Third = true
			pos = pos +ang:Right() *-1 +ang:Up() *-12
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_2)
		elseif self.Third then
			self.Third = nil
			self.Second = nil
			self.Fourth = true
			pos = pos +ang:Right() *10 +ang:Up() *-7
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_3)
		elseif self.Fourth then
			self.Third = nil
			self.Fourth = nil
			self.First = true
			pos = pos +ang:Right() *14 +ang:Up() *-12
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_4)
		end	
		
		local ent = ents.Create("ss_laser")
		ent:SetAngles(ang)
		ent:SetPos(pos +ang:Forward() *-48)
		ent:SetOwner(self.Owner)
		ent:SetDamage(self.Primary.Damage)
		ent:Spawn()
		ent:Activate()
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(ang:Up() *2 +ang:Forward() *4096 +ang:Right() *-2)
		end
	end
	self:HolsterDelay()
	self:IdleStuff()
	
	if ((game.SinglePlayer() && SERVER) || CLIENT) then
		self:SetNetworkedFloat("LastShootTime", CurTime())
	end	
end

function SWEP:SpecialThink()
	if self.Owner:KeyReleased(IN_ATTACK) then
		self:OnRemove()
	end
end

function SWEP:OnRemove()
	self.Attack = nil
	self.First = nil
	self.Second = nil
	self.Third = nil
	self.Fourth = nil
end

function SWEP:Holster()
	if self.DisableHolster then
		return false
	end
	self:OnRemove()
	return true
end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_laser.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_laser.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/laser/Fire.wav")
SWEP.Primary.Damage			= 7
SWEP.Primary.Delay			= .1
SWEP.Primary.DefaultClip	= 50
SWEP.Primary.Ammo			= "ar2"

SWEP.LaserPos				= true