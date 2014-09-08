
if CLIENT then

	SWEP.PrintName			= "CSS FAMAS"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.WepIcon			= "icons/serioussam/Colt"
	killicon.AddFont( "weapon_cs_famas", "csd", "t", Color(255, 100, 100, 100) )
	SWEP.ViewModelFlip = false

end



function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:Attack()
	self:SeriousFlash()
	self:IdleStuff()
end

function SWEP:SecondaryAttack()
	--[[if !self:CanPrimaryAttack() then return end
	if !self:CanSecondaryAttack() then return end
	

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	
	
	
	for i=1, 3 do 
		timer.Simple(i*0.08 - 0.08, function()
			if self.Weapon:Clip1() < 1 then return end
			if !self:CanPrimaryAttack() then return end
			if !self:CanSecondaryAttack() then return end
			self:Attack()
			self:SeriousFlash()
			self:IdleStuff()
			self:SetNextPrimaryFire(CurTime() + self.Primary.Delay*2)	
			self:SetNextSecondaryFire(CurTime() + self.Primary.Delay*2)	
		end)
	end
	
	--]]
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

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_ss_base"
SWEP.Category			= "Counter-Strike Source Weapons"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/weapons/v_rif_famas.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_famas.mdl"

SWEP.Primary.Damage			= 29
SWEP.Primary.Sound			= Sound("weapons/famas/famas-1.wav")
SWEP.Primary.Cone			= .01
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 90
SWEP.Primary.Delay			= .15
--SWEP.Primary.Ammo			= "smg1"
SWEP.Primary.RecoilMul	= 1

SWEP.ReloadSound			= ""