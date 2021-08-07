AttackTask = {}
AttackTask.__index = AttackTask

function AttackTask:new(superSurvivor)

	local o = {}
	setmetatable(o, self)
	self.__index = self
		
	o.parent = superSurvivor
	o.Name = "Attack"
	o.OnGoing = false
	--o.parent:Speak("starting attack")
	
	return o

end

function AttackTask:isComplete()
	--self.parent.player:Say( tostring(self.parent:needToFollow()) ..",".. tostring(self.parent:getDangerSeenCount() > 0) ..",".. tostring(self.parent.LastEnemeySeen) ..",".. tostring(not self.parent.LastEnemeySeen:isDead()) ..",".. tostring(self.parent:HasInjury() == false) )
	if(not self.parent:needToFollow()) and ((self.parent:getDangerSeenCount() > 0) or (self.parent:isEnemyInRange(self.parent.LastEnemeySeen) and self.parent:hasWeapon())) and (self.parent.LastEnemeySeen) and not self.parent.LastEnemeySeen:isDead() and (self.parent:HasInjury() == false) then return false
	else 
		self.parent:StopWalk()
		return true 
	end
end

function AttackTask:isValid()
	if (not self.parent) or (not self.parent.LastEnemeySeen) or (not self.parent:isInSameRoom(self.parent.LastEnemeySeen)) or (self.parent.LastEnemeySeen:isDead()) then return false 
	else return true end
end

function AttackTask:update()
	--print(self.parent:getName().. " AttackTask:update" )
	if(not self:isValid()) or (self:isComplete()) then return false end
	local theDistance = getDistanceBetween(self.parent.LastEnemeySeen, self.parent.player)
	
	if(self.parent:usingGun()) and (self.parent:isWalkingPermitted()) and (theDistance < 2.0) then
		local sq = getFleeSquare(self.parent.player,self.parent.LastEnemeySeen)
		self.parent:walkToDirect(sq)
		self.parent:DebugSay("backing away cuz i got gun" )
	elseif(self.parent.player:IsAttackRange(self.parent.LastEnemeySeen:getX(),self.parent.LastEnemeySeen:getY(),self.parent.LastEnemeySeen:getZ())) or (theDistance < 0.65 )then
			--print(self.parent:getName().. " int attack range !" )
			local weapon = self.parent.player:getPrimaryHandItem()
			if(not weapon or (not self.parent:usingGun()) or ISReloadWeaponAction.canShoot(weapon))  then
				--print(self.parent:getName().. " can shoot/attack " )
				self.parent:Attack(self.parent.LastEnemeySeen) 			
			elseif(self.parent:usingGun()) then
				if(self.parent:ReadyGun(weapon) == false) then self.parent:reEquipMele() end
				--print(self.parent:getName().. " trying to ready gun" )
				--self.parent:Wait(1)
			end	
			--if(self.parent:usingGun()) then self.parent.Reducer = 0 end -- force delay when using gun
		
	elseif(self.parent:isWalkingPermitted()) then
		
		local cs = self.parent.LastEnemeySeen:getCurrentSquare()
		if(instanceof(self.parent.LastEnemeySeen,"IsoPlayer")) then
		self.parent:walkToDirect(cs)
		else
			local fs = cs:getTileInDirection(self.parent.LastEnemeySeen:getDir())
			if(fs) and (fs:isFree(true)) then
				self.parent:walkToDirect(fs)
			else 
				self.parent:walkToDirect(cs)
			end
		end
			
		self.parent:DebugSay("walking close to attack:"..tostring(theDistance))
	else
		self.parent:DebugSay("something is wrong")
	end
	return true
	
end
