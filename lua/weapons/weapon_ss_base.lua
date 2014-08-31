
if SERVER then

	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
	CreateConVar("ss_unlimitedammo", 0)
end

if CLIENT then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFlip		= false
	SWEP.ViewModelFOV		= 60
	SWEP.BobScale			= 0
	SWEP.SwayScale			= .1
	CreateClientConVar("ss_crosshair", 1)
	CreateClientConVar("ss_firelight", 1)

end

game.AddAmmoType({
	name = "Cannonball",
})

SWEP.Author					= "Upset"
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions			= ""
SWEP.Category				= "Serious Sam"
SWEP.Spawnable				= false
--SWEP.UseHands			= true

SWEP.Primary.Damage			= 10
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.RecoilMul	= 1
SWEP.Primary.Ammo			= "none"
SWEP.Secondary.Ammo			= "none"


SWEP.AmmoToTake				= 1

SWEP.MuzzleScale			= 14
SWEP.EnableSmoke			= false

SWEP.DeployDelay			= 1.6

SWEP.EnableIdle				= false

SWEP.LaserPos				= false

SWEP.SBobScale				= 1

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self:SetDeploySpeed(self.DeployDelay)
	util.PrecacheSound(self.Primary.Sound)
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:IdleStuff()
	return true
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:WeaponSound(self.Primary.Sound)
	self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone)
	self:SeriousFlash()
	self:TakeAmmo(self.AmmoToTake)
	self:IdleStuff()
	self:HolsterDelay()
end

function SWEP:SecondaryAttack()
end

function SWEP:WeaponSound(snd)
	if SERVER then self.Owner:EmitSound(snd, 100, 100) end
end

function SWEP:HolsterDelay()
	self.DisableHolster = CurTime() +self.Primary.Delay -.3
end

function SWEP:Holster()
	if self.DisableHolster then
		return false
	end
	return true
end

function SWEP:Think()
	self:SpecialThink()
	
	if self.DisableHolster and CurTime() > self.DisableHolster then
		self.DisableHolster = nil
	end
	
	if CLIENT and self.EnableIdle then return end
	if self.idledelay and CurTime() > self.idledelay then
		self.idledelay = nil
		self.fidgetdelay = CurTime() +self:SequenceDuration() +math.Rand(10,12)
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
	
	if self.fidgetdelay and CurTime() > self.fidgetdelay then
		self.fidgetdelay = nil
		if self:LookupSequence("idle2") == -1 then return end
		self:SendWeaponAnim(ACT_VM_FIDGET)
		self.idledelay = CurTime() +self:SequenceDuration()
	end
end

function SWEP:SpecialThink()
end

function SWEP:ShootBullet(dmg, numbul, cone)


	local Kick = -(dmg*numbul/20)/2*self.Primary.RecoilMul

	if CLIENT or game.SinglePlayer() then
		timer.Simple(0.01,function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then return end
			self.Owner:SetEyeAngles( self.Owner:EyeAngles() + Angle(Kick,Kick*math.Rand(-1,1)*0.5,0)*2 )
		end)
	end
	
	self.Owner:ViewPunch(Angle(Kick,Kick*math.Rand(-1,1)*0.5,0))
	
	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos() 
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector(cone, cone, 0)
	bullet.Tracer	= 3
	bullet.Force	= dmg/10
	bullet.Damage	= dmg
	self.Owner:FireBullets(bullet)


	

	
	
end

function SWEP:CanPrimaryAttack()
	local ammo
	if self.AmmoToTake == 2 then
		ammo = 1
	else
		ammo = 0
	end

	if !self.Owner:IsNPC() then
		if self.Owner:GetAmmoCount(self.Primary.Ammo) <= ammo then
			self:SetNextPrimaryFire(CurTime() + .2)
			return false
		end
	end
	return true
end

function SWEP:SeriousFlash()
	if !IsFirstTimePredicted() then return end
	local fx = EffectData()
	fx:SetEntity(self.Weapon)
	fx:SetOrigin(self.Owner:GetShootPos())
	fx:SetNormal(self.Owner:GetAimVector())
	fx:SetAttachment(1)
	fx:SetScale(self.MuzzleScale)
	util.Effect("ss_mflash", fx)
	if self.EnableSmoke then
		util.Effect("ss_mflashsmoke", fx)
	end
end

function SWEP:ManySmoke()
	if self.SmokeAmount > 8 then
		timer.Simple(.1,function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then return end
			self:Smoke()
		end)
	end
	if self.SmokeAmount > 16 then
		timer.Simple(.2,function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then return end
			self:Smoke()
		end)
	end	
	if self.SmokeAmount > 64 then
		timer.Simple(.3,function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then return end
			self:Smoke()
		end)
		timer.Simple(.4,function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then return end
			self:Smoke()
		end)
	end
	if self.SmokeAmount > 100 then
		timer.Simple(.5,function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then return end
			self:Smoke()
		end)
		timer.Simple(.6,function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then return end
			self:Smoke()
		end)
		timer.Simple(.7,function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then return end
			self:Smoke()
		end)
		timer.Simple(.8,function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then return end
			self:Smoke()
		end)
	end
	self.SmokeAmount = 0
end

function SWEP:Smoke()
	self.EndSmoke = nil
	if !IsFirstTimePredicted() then return end
	local fx = EffectData()
	fx:SetEntity(self.Weapon)
	fx:SetOrigin(self.Owner:GetShootPos())
	fx:SetNormal(self.Owner:GetAimVector())
	fx:SetAttachment(1)
	util.Effect("ss_mflashsmoke", fx)
end

function SWEP:Reload()
end

function SWEP:TakeAmmo(num)
	if SERVER then
		if GetConVarNumber("ss_unlimitedammo") == 0 then
			if !self.Owner:IsNPC() then self:TakePrimaryAmmo(num) end
		end
	end	
end

function SWEP:IdleStuff()
	if CLIENT and self.EnableIdle then return end
	self.fidgetdelay = nil
	self.idledelay = CurTime() +self:SequenceDuration()
end

local sam = "models/pechenko_121/samclassic.mdl"

hook.Add("SetupMove", "samjumpsound", function(ply, move)
	if bit.band(move:GetButtons(), IN_JUMP) ~= 0 and bit.band(move:GetOldButtons(), IN_JUMP) == 0 and ply:OnGround() and ply:WaterLevel() < 2 and ply:Alive() and !ply:InVehicle() then
		if CLIENT then return end
		if ply:GetModel() == sam then
			if !ply.JumpSoundDelay then
				ply.JumpSoundDelay = CurTime()
			end

			if ply.JumpSoundDelay and ply.JumpSoundDelay <= CurTime() then
				ply:EmitSound("player/serioussam/Jump.wav", 80, 100)
				ply.JumpSoundDelay = CurTime() + .2
			end
		end
	end
end)

hook.Add("PlayerHurt", "samplayerhurt", function(ply, at, h, dmg)	
	if ply:GetModel() == sam and ply:Health() > 0 then
		if !ply.SoundDelay then
			ply.SoundDelay = CurTime()
		end

		if ply.SoundDelay and ply.SoundDelay <= CurTime() then
			local pitch = math.Rand(92,112)
			if ply:WaterLevel() == 3 then
				ply:EmitSound("player/serioussam/WoundWater.wav", 80, pitch)
			elseif dmg > 30 then
				ply:EmitSound("player/serioussam/WoundStrong.wav", 80, pitch)
			elseif dmg >= 15 then
				ply:EmitSound("player/serioussam/WoundMedium.wav", 80, pitch)
			elseif dmg < 15 then
				ply:EmitSound("player/serioussam/WoundWeak.wav", 80, pitch)
			end
			ply.SoundDelay = CurTime() + 0.45
		end
	end
end)

hook.Add("PlayerDeath", "samdeath", function(ply)
	if ply:GetModel() == sam then
		if ply:WaterLevel() == 3 then
			ply:EmitSound("player/serioussam/DeathWater.wav", 70, 100)
		elseif ply:WaterLevel() < 3 then
			ply:EmitSound("player/serioussam/Death.wav", 80, 100)
		end
	end
end)

if SERVER then return end

function SWEP:GetViewModelPosition(pos, ang)
	local reg = debug.getregistry()
	local GetVelocity = reg.Entity.GetVelocity
	local Length = reg.Vector.Length2D
	local vel = Length(GetVelocity(self.Owner))

	local hz = math.Clamp(vel/256, 0, .4)

	local moveright = math.sin(CurTime() * 11) *hz
	local moveup = math.sin(CurTime() * 11) *moveright /2
	
	local bobscale = self.SBobScale

	if self.Owner:OnGround() then
		pos = pos + moveright *bobscale * ang:Right()
		pos = pos + moveup *bobscale * ang:Up()
	end
	
	if self.EnableIdle then
		pos = pos + math.sin(CurTime() * 1.3) * ang:Up() /26
	end
	
	if self.LaserPos then
		local LastShootTime = self:GetNetworkedFloat("LastShootTime", 0)
		local scale = (-1 + math.Clamp((CurTime() - LastShootTime) * 3, 0, 1))
		pos = pos + scale * ang:Forward()
		ang:RotateAroundAxis(ang:Right(), 4.5)
	end

	return pos, ang
end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	surface.SetDrawColor(255, 255, 255, 245)
	surface.SetTexture(surface.GetTextureID(self.WepIcon))

	y = y - 20
	x = x + 15
	wide = wide - 32

	surface.DrawTexturedRect(x, y, wide, wide)
end

function SWEP:DrawHUD()
	self:Crosshair()
end

function SWEP:Crosshair()
	local x, y		
	if (self.Owner == LocalPlayer() && self.Owner:ShouldDrawLocalPlayer()) then
		local tr = util.GetPlayerTrace(self.Owner)
		local trace = util.TraceLine(tr)
		local coords = trace.HitPos:ToScreen()
		x, y = coords.x, coords.y
	else
		x, y = ScrW() / 2, ScrH() / 2
	end

	local dist = math.Round(-self.Owner:GetPos():Distance(self.Owner:GetEyeTraceNoCursor().HitPos) /12) +64
	dist = math.Clamp(dist, 32, 128)

	local getcvar = GetConVarNumber("ss_crosshair")
	if getcvar <= 0 or getcvar > 7 then return end
	surface.SetTexture(surface.GetTextureID("vgui/serioussam/Crosshair"..getcvar))
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(x - dist /2 -1, y - dist /2 +1, dist, dist)
end