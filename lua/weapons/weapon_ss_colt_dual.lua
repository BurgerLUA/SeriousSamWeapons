
if CLIENT then

	SWEP.PrintName			= "Schofield .45 (Dual)"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.ViewModelFlip		= true
	SWEP.WepIcon 			= "icons/serioussam/DoubleColt"
	killicon.Add("weapon_ss_colt_dual", SWEP.WepIcon, Color(255, 255, 255, 255))
	
end

function SWEP:Initialize()
	if CLIENT then
		self.LeftModel = ClientsideModel(self.WorldModel, RENDERGROUP_BOTH)
		self.LeftModel:SetNoDraw(true)
	end
	self:SetWeaponHoldType(self.HoldType)
	self:SetDeploySpeed(self.DeployDelay)
	util.PrecacheSound(self.Primary.Sound)
end

function SWEP:Deploy()
	self:IdleStuff()

	local vm = self.Owner:GetViewModel(1)
	vm:SetWeaponModel(self.ViewModel, self)

	self:SendWeaponAnimation(self:GetDeployActivity(), 0, 1.0)
	self:SendWeaponAnimation(self:GetDeployActivity(), 1, 1.0)
	return true
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SendWeaponAnimation(self:GetPrimaryAttackActivity(), 1, 1.0)
	self:Attack()
	
	self.shoot = CurTime() +.2
end

function SWEP:Think()
	self:SpecialThink()
	
	if self.DisableHolster and CurTime() > self.DisableHolster then
		self.DisableHolster = nil
	end
	
	if self.NextReload and CurTime() > self.NextReload then
		self.NextReload = nil
	end
	
	if self.shoot and CurTime() > self.shoot then
		self.shoot = nil
		self:Attack()
		self:SendWeaponAnimation(self:GetPrimaryAttackActivity(), 0, 1.0)
		self:IdleStuff()
	end
	
	if CLIENT then return end
	if self.idledelay and CurTime() > self.idledelay then
		self.idledelay = nil
		self.fidgetdelay = CurTime() +self:SequenceDuration() +math.random(10,12)
		self:SendWeaponAnimation(self:GetIdleActivity(), 0, 1.0)
		self:SendWeaponAnimation(self:GetIdleActivity(), 1, 1.0)
	end
	
	if self.fidgetdelay and CurTime() > self.fidgetdelay then
		self.fidgetdelay = nil
		self:SendWeaponAnim(ACT_VM_FIDGET)
		self.idledelay = CurTime() +self:SequenceDuration()
	end
end

function SWEP:Reload()
	if self:Clip1() > 0 and self.NextReload then return end
	if self:Clip1() >= self.Primary.ClipSize then return end
	self.idledelay = nil
	self.DisableHolster = CurTime() +1.4
	self:SendWeaponAnimation(self:GetReloadActivity(), 1, 1.0)
	self.Owner:SetAnimation(PLAYER_RELOAD)
	self:SetClip1(self.Primary.ClipSize)
	self:EmitSound(self.ReloadSound)
	self:SetNextPrimaryFire(CurTime() +1.4)
	
	timer.Simple(.6, function()
		if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then return end
		self:SendWeaponAnimation(self:GetReloadActivity(), 0, 1.0)
		if SERVER then self.Owner:EmitSound(self.ReloadSound) end
		self:IdleStuff()
	end)
end

function SWEP:Holster()
	if self.DisableHolster or self.shoot then
		return false
	end
	self.shoot = nil
	if SERVER then
		local owner = self:GetOwner()

		if(owner && owner:IsValid() && owner:IsPlayer()) then
			owner:GetViewModel(1):AddEffects(EF_NODRAW)
		end
	end
	return true
end

function SWEP:SendWeaponAnimation(anim, idx, pbr)

	idx = idx or 0
	pbr = pbr or 1.0
	
	local owner = self:GetOwner()
		
	if (owner && owner:IsValid() && owner:IsPlayer()) then
	
		local vm = owner:GetViewModel(idx)
	
		local idealSequence = self:SelectWeightedSequence(anim)
		local nextSequence = self:FindTransitionSequence(self:GetSequence(), idealSequence)
		
		vm:RemoveEffects(EF_NODRAW)
		vm:SetPlaybackRate(pbr)

		if (nextSequence > 0) then
			vm:SendViewModelMatchingSequence(nextSequence)
		else
			vm:SendViewModelMatchingSequence(idealSequence)
		end

		return vm:SequenceDuration(vm:GetSequence())
	end
end

function SWEP:GetDeployActivity()
	return ACT_VM_DRAW
end

function SWEP:GetPrimaryAttackActivity()
	return ACT_VM_PRIMARYATTACK
end

function SWEP:GetIdleActivity()
	return ACT_VM_IDLE
end

function SWEP:GetReloadActivity()
	return ACT_VM_RELOAD
end

function SWEP:DrawWorldModel()
	local lhand, LHandAT
	
	if !IsValid(self.Owner) then
		self:DrawModel()
		return
	end
	
	if !LHandAT then
		LHandAT = self.Owner:LookupAttachment("anim_attachment_lh")
	end

	lhand = self.Owner:GetAttachment(LHandAT)
	
	if !lhand then
		self:DrawModel()
		return
	end

	loffset = lhand.Ang:Forward() * 7.6 + lhand.Ang:Up() * 2
	
	lhand.Ang:RotateAroundAxis(lhand.Ang:Right(), 0)
	lhand.Ang:RotateAroundAxis(lhand.Ang:Forward(), 0)
	lhand.Ang:RotateAroundAxis(lhand.Ang:Up(), 175)
	
	self.LeftModel:SetRenderOrigin(lhand.Pos + loffset)
	self.LeftModel:SetRenderAngles(lhand.Ang)	
	self.LeftModel:DrawModel()
	
	self:DrawModel()
end

SWEP.HoldType			= "duel"
SWEP.Base				= "weapon_ss_colt"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.Primary.Damage			= 30
SWEP.Primary.Delay			= .23
SWEP.Primary.ClipSize		= 12
SWEP.Primary.DefaultClip	= 12