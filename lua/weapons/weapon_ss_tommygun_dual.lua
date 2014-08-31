
if CLIENT then

	SWEP.PrintName			= "M1-A2 Thompson (Dual)"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.ViewModelFOV		= 50
	SWEP.ViewModelFlip		= true
	SWEP.SwayScale			= 0.025
	SWEP.WepIcon 			= "icons/serioussam/DoubleColt"
	killicon.Add("weapon_ss_tommygun_dual", SWEP.WepIcon, Color(255, 255, 255, 255))
	
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
	
	self.shoot = CurTime() + 0.075/2
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
SWEP.Base				= "weapon_ss_tommygun"
SWEP.Category			= "Serious Sam"
SWEP.Spawnable			= true

SWEP.Primary.Damage			= 8
SWEP.Primary.Cone			= .08
SWEP.Primary.Delay			= 0.075
SWEP.Primary.DefaultClip	= 200
SWEP.Primary.RecoilMul	= 2