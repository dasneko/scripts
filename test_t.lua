if myHero.charName ~= "Riven" or not VIP_USER then return end

local myPlayer			=	GetMyHero()

local AABuff = "rivenpassiveaaboost"
local aaboost, CanUseQ, Target = false, true, nil
local lastAttack, lastWindUpTime, lastAttackCD = 0, 0, 0
local myTrueRange 							   = myPlayer.range + GetDistance(myPlayer.minBBox)
local qCount = 0
local qTick, rTick = 0, 0

function OnLoad()
	menu = scriptConfig("Test", "test")
	menu:addParam("key", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Ts		=	TargetSelector(TARGET_NEAR_MOUSE, 825, DAMAGE_PHYSICAL)
	Ts.name 	= 	"Riven"
	menu:addTS(Ts)
	PrintChat("ok jus let's do it")
end

function OnGainBuff(unit, buff)	
	if unit.isMe then		
		if buff.name:lower():find("rivenpassiveaaboost") then aaboost = true end
		PrintChat(buff.name)
	end
end

function OnLoseBuff(unit, buff)	
	if unit.isMe then		
		if buff.name:lower():find("rivenpassiveaaboost") then aaboost = false end
	end
end

function OnProcessSpell(object, spell)
	if object == myPlayer then
		if spell.name:lower():find("attack") then			
			lastAttack = GetTickCount() - GetLatency() / 2
			lastWindUpTime = spell.windUpTime * 1000
			lastAttackCD = spell.animationTime * 1000	
			--PrintChat("windUpTime: "..tostring(spell.windUpTime))
			--PrintChat("animationTime: "..tostring(spell.animationTime))
			--PrintChat("lastAttack: "..tostring(lastAttack))		
		end 
	end

	if spell.name == "RivenTriCleave" then 
	qTick = GetTickCount()         
        if ValidTarget(Target) then
        
        local movePos = Target + (Vector(myPlayer) - Target):normalized()*(GetDistance(Target)+50)
            if movePos then
                Packet('S_MOVE', {x = movePos.x, y = movePos.z}):send()
            end
    	end
    end

    if spell.name == "RivenFengShuiEngine" then
   	rTick = GetTickCount()
   	end

end

function _OrbWalk(myTarget)	
	if ValidTarget(myTarget, myTrueRange) then		
		if timeToShoot() then
			myPlayer:Attack(myTarget)			
		elseif heroCanMove()  then
			moveToCursor()
		end
	else		
		moveToCursor() 
	end
end
function OwYew(myTarget)
	return aaboost and qCount > 0 and ValidTarget(myTarget, myTrueRange)
end

function heroCanMove()
	return (GetTickCount() + GetLatency() / 2 > lastAttack + lastWindUpTime)
end 
 
function timeToShoot()
	return OwYew(Target) or (GetTickCount() + GetLatency() / 2 > lastAttack + lastAttackCD)
end 

function moveToCursor()
	if GetDistance(mousePos) > myTrueRange then
		local moveToPos = myPlayer + (Vector(mousePos) - myPlayer):normalized() * 250
		myPlayer:MoveTo(moveToPos.x, moveToPos.z)
	end 
end

--[[my send packet
function OnSendPacket(packet)
	local PacketCast 	= Packet(packet)
	local PacketToSend	= CLoLPacket(71)
	if PacketCast:get('name') == 'S_CAST' and PacketCast:get('spellId') == _Q then
		PacketToSend.pos = 1
		PacketToSend:EncodeF(myPlayer.networkID)
		PacketToSend:Encode1(2)
		PacketToSend:Encode1(0)			
		SendPacket(PacketToSend)
	end
end
]]

function CastQ(myTarget)
	if ValidTarget(Target) and myPlayer:CanUseSpell(_Q) == READY and not timeToShoot() then
		CastSpell(_Q, myTarget.x, myTarget.z)		
	end
	if ValidTarget(Target) and myPlayer:CanUseSpell(_Q) == READY and GetDistance(myTarget) <= 550 and GetDistance(myTarget) >= 385 and timeToShoot() then
		CastSpell(_Q, myTarget.x, myTarget.z)
	end	
end

function KillEverybodyMothaFucker(myTarget)
	if ValidTarget(myTarget) then
		if myPlayer:CanUseSpell(_R) == READY and qCount > 2 then
			CastSpell(_R)
		end
		if myPlayer:CanUseSpell(_R) == READY and GetTickCount() > rTick + 15000 or (myTarget.health / myTarget.maxHealth)*100 < 10 then
			CastSpell(_R, myTarget.x, myTarget.z)
		end
		CastQ(myTarget)
		if myPlayer:CanUseSpell(_E) == READY and GetDistance(myTarget) <= 385 and not timeToShoot() then
        	CastSpell(_E, myTarget.x, myTarget.z)
    	end
    	if myPlayer:CanUseSpell(_E) == READY and GetDistance(myTarget) <= 385 and GetDistance(myTarget) >= 125 and timeToShoot() then
    		CastSpell(_E, myTarget.x, myTarget.z)
    	end
   		if myPlayer:CanUseSpell(_W) == READY and GetDistance(myTarget) < 260 then
        	CastSpell(_W)
    	end
	end
end

function OnAnimation(unit,animation)
    if unit.isMe and animation:find("Spell1a") then
        qCount = 1
    elseif unit.isMe and animation:find("Spell1b") then
        qCount = 2
    elseif unit.isMe and animation:find("Spell1c") then
        qCount = 3
    end
end


function OnSendPacket(p)
	if p.header == Packet.headers.S_CAST then
		local decodedPacket = Packet(p)
		if decodedPacket:get('spellId') == _Q then Emote() end
	end
end

function Emote()
	p = CLoLPacket(0x47)
	p:EncodeF(myPlayer.networkID)
	p:Encode1(2)
	p.dwArg1 = 1
	p.dwArg2 = 0
	SendPacket(p)
end


function OnTick()
	Ts:update()
	Target = Ts.target
	if menu.key then			
		KillEverybodyMothaFucker(Target)		
		_OrbWalk(Target)		
	end
	if myPlayer:GetSpellData(_Q).cd == 13 then qCount = 0 end	
	--PrintChat(tostring(myPlayer:GetSpellData(_Q).cd))		
end
