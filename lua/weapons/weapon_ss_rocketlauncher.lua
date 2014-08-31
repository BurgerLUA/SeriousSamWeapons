
if CLIENT then

	SWEP.PrintName			= "XPML21 Rocket Launcher"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 1
	SWEP.ViewModelFOV		= 65
	SWEP.WepIcon			= "icons/serioussam/RocketLauncher"
	killicon.Add("ss_rocket", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:PrimaryAttack()



	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	
	dmg = self.Primary.Damage
	numbul = 1


	self:IdleStuff()
	self:Attack()
end

function SWEP:SecondaryAttack()



	if !self:CanSecondaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay*6)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay*6)

	dmg = self.Primary.Damage*0.75
	numbul = 1

	self:IdleStuff()
	
	timer.Create( "rockettimer" .. self.Owner:EntIndex(), 0.20, 4, function()
		if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then return end
		self:Attack()
	end)
end




function SWEP:Attack()

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	local Kick = -(dmg*numbul/20)/2*self.Primary.RecoilMul
	self:WeaponSound(self.Primary.Sound)
	self:TakeAmmo(1)


	if CLIENT or game.SinglePlayer() then
		timer.Simple(0.01,function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then return end
			self.Owner:SetEyeAngles( self.Owner:EyeAngles() + Angle(Kick,Kick*math.Rand(-1,1)*0.5,0)*2 )
		end)
	end

	self.Owner:ViewPunch(Angle(Kick,Kick*math.Rand(-1,1),0))

	if SERVER then
		local pos = self.Owner:GetShootPos()
		local ang = self.Owner:GetAimVector():Angle() + Angle(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))
		pos = pos +ang:Right() *1 +ang:Up() *-7 +ang:Forward() *-9
		local ent = ents.Create("ss_rocket")
		ent:SetAngles(ang)
		ent:SetPos(pos)
		ent:SetOwner(self.Owner)
		ent:SetDamage(self.Primary.Damage)
		ent:Spawn()
		ent:Activate()
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(ang:Up() *4 +ang:Forward() *500)
		end
	end
	self:HolsterDelay()
end


SWEP.HoldType			= "crossbow"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_rocketlauncher.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_rocketlauncher.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/rocketlauncher/Fire.wav")
SWEP.Primary.Damage			= 50
SWEP.Primary.Delay			= 1.1
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Ammo			= "RPG_Round"
SWEP.Primary.RecoilMul = 2




