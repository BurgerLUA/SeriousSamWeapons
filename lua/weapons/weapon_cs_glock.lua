
if CLIENT then

	SWEP.PrintName			= "CSS GLOCK"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.WepIcon			= "icons/serioussam/Colt"
	killicon.AddFont( "weapon_cs_glock", "csd", "c", Color(255, 100, 100, 100) )
	SWEP.ViewModelFlip = true

end

function SWEP:PrimaryAttack()

	if !self:CanPrimaryAttack() then return end
	
	if self.FireMode == 1 then
		self.Primary.RecoilMul	= 1
		self.Primary.Cone = .02
		self:Attack()
		self:IdleStuff()
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)	
	elseif self.FireDelay < CurTime() then
		self.Primary.Cone = .01
		self.Primary.RecoilMul	= 0.5
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay*2)
		self:Attack()
		timer.Simple(self.Primary.Delay*0.5, function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then return end
			self:Attack()
		end)
		timer.Simple(self.Primary.Delay*1, function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then return end
			self:Attack()
		end)
		self.FireDelay = CurTime() + self.Primary.Delay*4
	end
		
end

function SWEP:SecondaryAttack()
	self:EmitSound("weapons/elite/elite_sliderelease.wav")
	if self.FireMode == 1 then
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Switched to Burst Fire Mode" )
		self.FireMode = 2
	else
		self.FireMode = 1
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Switched to Semi-Automatic" )
	end
end


function SWEP:Attack()
	if !self:CanPrimaryAttack() then return end
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:SeriousFlash()
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

SWEP.HoldType			= "pistol"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Counter-Strike Source Weapons"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/v_pist_glock18.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_glock18.mdl"

SWEP.Primary.Damage			= 25
SWEP.Primary.Sound			= Sound("weapons/glock/glock18-1.wav")
SWEP.Primary.Automatic = false
SWEP.Primary.Cone			= .01
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 60
SWEP.Primary.Delay			= 0.05
--SWEP.Primary.Ammo			= "smg1"
SWEP.Primary.RecoilMul	= 1



SWEP.ReloadSound			= ""

SWEP.Firemode = 1
SWEP.FireDelay = 0