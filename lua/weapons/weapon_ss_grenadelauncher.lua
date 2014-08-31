
if CLIENT then

	SWEP.PrintName			= "MK III Grenade Launcher"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 1
	SWEP.ViewModelFOV		= 48
	SWEP.WepIcon			= "icons/serioussam/GrenadeLauncher"
	killicon.Add("ss_grenade", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end	
	self:SetNextPrimaryFire(CurTime() +2)
	self:SetNextSecondaryFire(CurTime() +2)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_1)
	self.bInAttack = true
	self.attackStart = CurTime() +.1
	self.rdelay = CurTime() +.85
end

function SWEP:SecondaryAttack()
	if !self:CanSecondaryAttack() then return end	
		self:SetNextPrimaryFire(CurTime() + 5)
		self:SetNextSecondaryFire(CurTime() + 5)
		

		
	timer.Create( "nadedroptimer" .. self.Owner:EntIndex(), 0.20, 3, function()	
		if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then return end
		self.attackStart = CurTime() - 0.05
		self.rdelay = CurTime() +.85
		self:Release()
	end)

end


function SWEP:SpecialThink()
	if self.rdelay and CurTime() > self.rdelay then
		self:Release()
	end
	if !self.bInAttack || self.Owner:KeyDown(IN_ATTACK) || CurTime() < self.attackStart then return end
	self:Release()
end	

function SWEP:Release()
	self.bInAttack = nil
	self.rdelay = nil
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:WeaponSound(self.Primary.Sound)
	self:TakeAmmo(1)
	self:HolsterDelay()
	
	local damage = self.Primary.Damage + (self.Primary.Damage * (CurTime() - self.attackStart))*0.25
	damage = math.Round(damage)
	
	
	
	local Kick = (self.Primary.Damage - damage)/4

	if CLIENT or game.SinglePlayer() then
		timer.Simple(0.01,function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then return end
			self.Owner:SetEyeAngles( self.Owner:EyeAngles() + Angle(Kick,Kick*math.Rand((-1,1)*0.5,0)*2 )
		end)
	end
	
	self.Owner:ViewPunch(Angle(Kick,Kick*math.Rand((-1,1)*0.5,0))
	
	--print(Kick)
	
	
	
	
	if CLIENT then return end
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector():Angle()
	//Wiki says:
	//A maximally-charged grenade deals more damage than a rocket
	//but i fucking dont know HOW EXACTLY more damage
	--local damage = self.Primary.Damage + (self.Primary.Damage * (CurTime() - self.attackStart))*0.25
	--damage = math.Round(damage)
	pos = pos +ang:Forward() *0 +ang:Right() *3 +ang:Up() *-18
	local ent = ents.Create("ss_grenade")
	ent:SetPos(pos)
	ent:SetAngles(ang + Angle(math.Rand(-10,10),math.Rand(-10,10),math.Rand(-10,10)))
	ent:SetOwner(self.Owner)
	ent:SetExplodeDelay(2.5)
	ent:SetDamage(damage)
	ent:Spawn()
	ent:Activate()
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		local vel = ang:Forward() *(8000 *(CurTime() -(self.attackStart -.2))) +ang:Up() *1000 
		phys:ApplyForceCenter(vel+self.Owner:GetVelocity())
	end
end

function SWEP:OnRemove()
	self.bInAttack = nil
	self.rdelay = nil
	self.attackStart = nil
	return true
end

function SWEP:Holster()
	if self.DisableHolster or self.bInAttack then
		return false
	end
	self:OnRemove()
	return true
end

SWEP.HoldType			= "crossbow"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/serioussam/v_grenadelauncher.mdl"
SWEP.WorldModel			= "models/weapons/serioussam/w_grenadelauncher.mdl"

SWEP.Primary.Sound			= Sound("weapons/serioussam/grenadelauncher/Fire.wav")
SWEP.Primary.Damage			= 95
SWEP.Primary.Delay			= 1
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Ammo			= "Grenade"

SWEP.EnableIdle				= true