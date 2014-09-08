
if CLIENT then

	SWEP.PrintName			= "CSS XM1014"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.WepIcon			= "icons/serioussam/Colt"
	killicon.AddFont( "weapon_cs_xm1014", "csd", "B", Color(255, 100, 100, 100) )
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
	
	if not self.ReloadingTime then 
		self.ReloadingTime = 0
	end
	
	if self.ReloadingTime > CurTime() then return end
	
	self.DisableHolster = CurTime() + 1
	self.ReloadingTime = CurTime() + self.Primary.ClipSize-self:Clip1()
	
	self.ShellTime = 0.6
	
	
	for i=1, self.Primary.ClipSize-self:Clip1() do
		timer.Simple(i*self.ShellTime - self.ShellTime,function()
			self:SetClip1(self:Clip1()+1)
			self:EmitSound(self.ReloadSound)
			--self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_START)
			self:SendWeaponAnim( ACT_VM_RELOAD )
		end)

	end

	timer.Simple((self.Primary.ClipSize-self:Clip1())*self.ShellTime, function() self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH ) end)
	
	self.Owner:SetAnimation(PLAYER_RELOAD)
	
	
	self:SetNextPrimaryFire(CurTime() + self.ShellTime*(self.Primary.ClipSize-self:Clip1()))
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

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Counter-Strike Source Weapons"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/v_shot_xm1014.mdl"
SWEP.WorldModel			= "models/weapons/w_shot_xm1014.mdl"

SWEP.Primary.Damage			= 105/12
SWEP.Primary.Sound			= Sound("weapons/xm1014/xm1014-1.wav")
SWEP.Primary.Cone			= .2
SWEP.Primary.NumShots		= 12
SWEP.Primary.ClipSize		= 7
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Delay			= 0.3
--SWEP.Primary.Ammo			= "smg1"
SWEP.Primary.RecoilMul	= 1.25
SWEP.Primary.Automatic = false

SWEP.ReloadSound			= ""