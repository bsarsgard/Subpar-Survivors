
function SuperSurvivorPlayerInit(player)
		
			player:getModData().isHostile = false
			player:getModData().semiHostile = false
			player:getModData().hitByCharacter = false
			player:getModData().ID = 0
			player:setBlockMovement(false)
			player:setNPC(false)	
			print("initing player index " .. tostring(player:getPlayerNum()) )
			
			if(player:getPlayerNum()==0) then
				print("initing player index 0")
				SSM:init()
				MyGroup = SSGM:newGroup()
				MyGroup:addMember(SSM:Get(0),"Leader")			
				local spawnBuilding = SSM:Get(0):getBuilding()
				if(spawnBuilding) then -- spawn building is default group base
					print("set building "..tostring(MyGroup:getID()))
					local def = spawnBuilding:getDef()
					local bounds = {def:getX(),(def:getX() + def:getW()), def:getY(),(def:getY() + def:getH()),0}
					MyGroup:setBounds(bounds)
				else
					print("did not spawn in building")
				end
			
			
				local wife
				if(player:getModData().WifeID == nil) and (SuperSurvivorGetOptionValue("WifeSpawn") == true) then					
						
					player:getModData().WifeID = 0;
								
					wife = SSM:spawnSurvivor(not player:isFemale(), player:getCurrentSquare());
					
					local MData = wife:Get():getModData();
					--if(player:isFemale()) then
					--	wife:setName(getText("ContextMenu_SD_Husband"));
					--else
					--	wife:setName(getText("ContextMenu_SD_Wife"));
					--end
					
					wife:Get():getModData().InitGreeting = getSpeech("WifeIntro");
					wife:Get():getModData().seenZombie = true;
					MData.MetPlayer = true;
					MData.isHostile = false;
												
					local GID, Group
					if(SSM:Get(0):getGroupID() == nil) then
						print("SSGM:newGroup() "..tostring(SSGM:getCount()))
						Group = SSGM:newGroup()
						GID = Group:getID()					
						Group:addMember(SSM:Get(0),"Leader")
						print("POST SSGM:newGroup() "..tostring(SSGM:getCount()))
					else
						GID = SSM:Get(0):getGroupID()
						print("main player has group id detected:"..tostring(GID))
						Group = SSGM:Get(GID)
					end
					
					Group:addMember(wife,"Worker")
					
					local followtask = FollowTask:new(wife,getSpecificPlayer(0))
					local tm = wife:getTaskManager()
					wife:setAIMode("Follow")
					tm:AddToTop(followtask)

					--if(ZombRand(100) < (ChanceToSpawnWithGun)) then 
					--	wife:giveWeapon(getWeapon(RangeWeapons[ZombRand(1,#RangeWeapons)]),true) 				
					--elseif(ZombRand(100) < (ChanceToSpawnWithWep)) then 
					--	wife:giveWeapon(MeleWeapons[ZombRand(1,#MeleWeapons)],true) 
					--end
					
					GlobalWife = wife
					
				end
				
				if(player:getModData().LockNLoad == nil) and (SuperSurvivorGetOptionValue("LockNLoad") == true) then
					
					
					local SSME = SSM:Get(0)
					SSME:WearThis("Shoes_ArmyBoots")
					SSME:WearThis("Vest_BulletArmy")
					SSME:WearThis("Trousers_CamoGreen")
					SSME:WearThis("Shirt_CamoGreen")
					SSME:WearThis("Hat_Army")
					
					if(wife) then
						wife:WearThis("Shoes_ArmyBoots")
						wife:WearThis("Vest_BulletArmy")
						wife:WearThis("Trousers_CamoGreen")
						wife:WearThis("Shirt_CamoGreen")
						wife:WearThis("Hat_Army")
					end
					
					
						
					local gun = player:getInventory():AddItem("Base.Pistol");
					local mag
					for i=1, 4 do
						mag = player:getInventory():AddItem(gun:getMagazineType());
						mag:setCurrentAmmoCount(15)
					end
									
					player:getInventory():AddItem("Base.Bullets9mmBox");
					player:getInventory():AddItem("Base.Bullets9mmBox");
					player:getInventory():AddItem("Base.Bullets9mmBox");
					player:getInventory():AddItem("Base.Bullets9mmBox");
					
					--gun:setClip(mag)
					if(isModEnabled("Silencer")) then
						gun:setCanon(instanceItem("Silencer.Silencer"))
					end
					
					if(wife) then
						local pistol = wife:Get():getInventory():AddItem("Base.HuntingRifle");
						wife:Get():getInventory():AddItem("Base.308Clip");
						
						if(isModEnabled("Silencer")) then
							pistol:setCanon(instanceItem("Silencer.Silencer"))
						end
						wife:Get():setPrimaryHandItem(pistol)
						wife:Get():setSecondaryHandItem(pistol)
						
						for i=1, 12 do
							wife:Get():getInventory():AddItem("Base.308Bullets");
						end					
					end
						
					
					
					for i=1, 8 do player:LevelPerk(Perks.FromString("Aiming")) end
					for i=1, 8 do player:LevelPerk(Perks.FromString("Reloading")) end
					
					if(wife) then 
						for i=1, 8 do wife:Get():LevelPerk(Perks.FromString("Aiming")) end
					end
					
					player:getModData().LockNLoad = true
					
				end						
				
				local mydesc = getSpecificPlayer(0):getDescriptor()
				if(SSM:Get(0)) then SSM:Get(0):setName(mydesc:getForename()) end
			else	
				print("finished initing player index " .. tostring(player:getPlayerNum()) )
			end
end


function SuperSurvivorOnDeath(player)
		
	if(player and player:getModData().ID ~= nil) then
		
		local SS = SSM:Get(player:getModData().ID)
		if(SS ~= nil) then SS:OnDeath() end
	end
	
end
function SuperSurvivorGlobalUpdate(player)
		
	if(player and player:getModData().ID ~= nil) then
		
		local SS = SSM:Get(player:getModData().ID)
		if(SS ~= nil) then SS:PlayerUpdate() end
	end
	
end

function getCoverValue(obj)
	if (tostring(obj:getType()) == "wall") then return 0 -- walls behind player are blocking if on samve sqare
	elseif (obj:getObjectName() == "Tree") then return 25
	elseif (obj:getObjectName() == "Window") then return 70
	elseif (obj:getObjectName() == "Door") then return 80
	elseif (obj:getObjectName() == "Counter") then return 80
	elseif (obj:getObjectName() == "IsoObject") then return 10 -- drastically lowered because small stuff like garbage was blocking shots
	else return 0 end
end

function getGunShotWoundBP(player)

	if(not instanceof(player,"IsoPlayer")) then 
		print("not a player object was given to getGunshotwoundBP")
		return nil 
	end

	local BD = player:getBodyDamage()
	local bps = BD:getBodyParts() ;
	local foundBP = false
	local list = {};
	if(bps) then
		for i=1, bps:size()-1 do		
			if(bps:get(i) ~= nil) and ( bps:get(i):HasInjury() ) and ( bps:get(i):getHealth() > 0)  then
				table.insert(list,i);
				foundBP = true
			end
		end
	end
	if(not foundBP) then 
		print("no body part with gunshot wound")
		return nil 
	end
	local result = ZombRand(1,#list)
	local index = list[result]
	local outBP = bps:get(index)
	--print("body part found was: " .. tostring(outBP))
	return outBP
	
end


function SuperSurvivorPVPHandle(wielder, victim, weapon, damage)
	--print("weaponhitcharacter")

	--if wielder ~= nil then print("PVP " .. tostring(wielder:getForname())) end
	--if victim ~= nil then print("hit " .. tostring(victim:getForname())) end
	--if wielder ~= nil and instanceof(weilder, "IsoPlayer") then print("wpvp " .. tostring(wielder:getCoopPVP())) end
	--if victim ~= nil and instanceof(victim, "IsoPlayer") then print("vpvp " .. tostring(victim:getCoopPVP())) end
	local SSW = SSM:Get(wielder:getModData().ID)
	local SSV = SSM:Get(victim:getModData().ID)
	--if SSW ~= nil and SSW:getName() ~= nil then print("SSW " .. SSW:getName()) end
	--if SSV ~= nil and SSV:getName() ~= nil then print("SSV " .. SSV:getName()) end
	
	local fakehit = false
	
	if(SSV == nil) or (SSW == nil) then return false end
	
	if(victim.setAvoidDamage ~= nil) then
		if(SSW:isInGroup(victim)) then  
			--victim:Say("cant touch this!")
			print("cant touch this")
			fakehit = true
			victim:setAvoidDamage(true)		
		end
	elseif(victim.setNoDamage ~= nil) then
		if(SSW:isInGroup(victim)) then 
			--victim:Say("cant touch this!")
			print("cant touch this2")
			fakehit = true
			victim:setNoDamage(true)
		else
			victim:setNoDamage(false)
		end
	end
	if fakehit then return false end
	

	--[[ obj cover calculations
	if(instanceof(weapon,"HandWeapon")) and (weapon:isAimedFirearm()) and (instanceof(victim,"IsoPlayer")) then
		
		local angle = wielder:getAngle()
		local dir = IsoDirections.fromAngle(angle)
		dir = IsoDirections.reverse(dir)
		
		local victimSquare1 = victim:getCurrentSquare()
		local victimSquare2 = victimSquare1:getTileInDirection(dir)
		local coveredFire = false
		for q=1,2 do
			
			local objs
			if q == 1 then objs = victimSquare2:getObjects()
			else objs = victimSquare1:getObjects() end
			
			local aimingPerk = wielder:getPerkLevel(Perks.Aiming) 
			local hitChanceBonus = 0
			if wielder:HasTrait("Marksman") then hitChanceBonus = hitChanceBonus + 10 end
			if(objs) then
				for i=1, objs:size()-1 do
					if(objs:get(i)) then 
						local obj = objs:get(i)
						local chance = getCoverValue(obj) - (aimingPerk*3) - hitChanceBonus
						if ZombRand(100) < chance then
							coveredFire = true
							break
						end
					end
				end
			end
			if(coveredFire) then break end
		end
		
		
		
		if coveredFire then 
			SSV:Speak("!!") 
			if(victim.setAvoidDamage ~= nil) then victim:setAvoidDamage(true) end
			return false 	
		
		end
	end
	]]
	
	--- obj cover calculations	END
	
		-- add extra damage, bc bullet damage so low
		
			--if(LastGuyHit == nil) or (victim ~= LastGuyHit) then
			--	LastGuyHitCount = 1
			--	LastGuyHit = victim
			--elseif(victim ~= getSpecificPlayer(0)) then
			--	LastGuyHitCount = LastGuyHitCount + 1
			--end
			--if(victim ~= getSpecificPlayer(0)) then wielder:Say(tostring(LastGuyHitCount)) end
	
		--	local extraDamage = ZombRand(150,250);
			--print("here i am31")
			local extraDamage ;
			local shotPartshotPart = getGunShotWoundBP(victim)
			if(shotPartshotPart ~= nil) and (SSV:getID() ~= 0) then
				--if( shotPartshotPart:getType() == "Head") then extraDamage = 40 
				--elseif( shotPartshotPart:getType() == "Neck") then extraDamage = 30
				--elseif( shotPartshotPart:getType() == "Torso_Lower") then extraDamage = 30
				--elseif( shotPartshotPart:getType() == "Torso_Upper") then extraDamage = 35
				--end
				extraDamage = 100 --(damage*24)
				--print("added " .. tostring(extraDamage) .. " damage to gun shot wound on " .. tostring(shotPartshotPart:getType()) .. " to player number " .. tostring(victim:getModData().ID))
			--	print("pre getHealth is " .. tostring(shotPartshotPart:getHealth()))
				--print("pre getHealth is " .. tostring(victim:getBodyDamage():getHealth()))
				
				shotPartshotPart:AddDamage(extraDamage);
				shotPartshotPart:DamageUpdate();
				--victim:getBodyDamage():DamageFromWeapon(weapon);
				victim:update();
				
				--print("shotPartshotPart is " .. tostring(shotPartshotPart:getHealth()) ) 
				
			end
			--print("post getHealth is " .. tostring(victim:getBodyDamage():getHealth()) ) 
	
	
	if instanceof(victim, "IsoPlayer") then	
		local GroupID = SSV:getGroupID()
		if(GroupID ~= nil) then
			local group = SSGM:Get(GroupID)
			if(group) then
				group:PVPAlert(wielder)
			end
		else
			victim:getModData().hitByCharacter = true
		end
	end
	if(instanceof(victim, "IsoPlayer") ) then	

		if(weapon~=nil) and (not weapon:isAimedFirearm()) and (weapon:getPushBackMod() > 0.3) then
			victim:StopAllActionQueue()
			local dot = victim:getDotWithForwardDirection(wielder:getX(),wielder:getY());
			--print("dot="..tostring(dot))
			if(dot < 0) then 				
				ISTimedActionQueue.add(ISGetHitFromBehindAction:new(victim,wielder))
			elseif(dot > 0) then 
				ISTimedActionQueue.add(ISGetHitFromFrontAction:new(victim,wielder)) 
			end
		
		end
	
		wielder:getModData().semiHostile = true		
		if(victim:getModData().surender) and weapon and weapon:isRanged() then -- defenceless player hit, they die
				victim:getBodyDamage():getBodyPart(BodyPartType.Head):AddDamage(500);
				victim:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):AddDamage(500);
				victim:getBodyDamage():getBodyPart(BodyPartType.Hand_L):AddDamage(500);
				victim:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):AddDamage(500);
				victim:getBodyDamage():Update();
				
				SSM:PublicExecution(SSW,SSV)
		end
	end
	
	
	
end
Events.OnWeaponHitCharacter.Add(SuperSurvivorPVPHandle);
Events.OnPlayerUpdate.Add(SuperSurvivorGlobalUpdate);
Events.OnCharacterDeath.Add(SuperSurvivorOnDeath);

--function test1(wielder, weapon)
--	print "test1"
--end
--Events.OnWeaponSwingHitPoint.Add(test1);
--function test2(wielder, weapon)
--	print "attackfinished"
--end
--Events.OnPlayerAttackFinished.Add(test2);
--function test3(character, chargeDelta, weapon)
--	print("hookattack "..tostring(weapon))
--end
--Hook.Attack.Add(test3);
--function test4()
--	print "hitzombie"
--end
--Events.OnHitZombie.Add(test4)