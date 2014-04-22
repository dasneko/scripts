if myHero.charName ~= "Riven" or not VIP_USER then return end

local myPlayer			=	GetMyHero()

local AABuff = "rivenpassiveaaboost"
local aaboost, CanUseQ, Target = false, true, nil
local lastAttack, lastWindUpTime, lastAttackCD = 0, 0, 0
local myTrueRange 							   = myPlayer.range + GetDistance(myPlayer.minBBox)

function OnLoad()
	menu = scriptConfig("Test", "test")
	menu:addParam("key", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Ts		=	TargetSelector(TARGET_NEAR_MOUSE, 780, DAMAGE_PHYSICAL)
	Ts.name 	= 	"Riven"
	menu:addTS(Ts)
	PrintChat("ok jus let's do it")
end

function OnGainBuff(unit, buff)	
	if unit.isMe then		
		if buff.name:lower():find("rivenpassiveaaboost") then aaboost = true CanUseQ = false end
	end
end

function OnLoseBuff(unit, buff)	
	if unit.isMe then		
		if buff.name:lower():find("rivenpassiveaaboost") then aaboost = false CanUseQ = true end
	end
end

function CastQ(myTarget)
	if ValidTarget(Target) and myPlayer:CanUseSpell(_Q) == READY and CanUseQ then
		CastSpell(_Q, myTarget.x, myTarget.z)		
	end
end

function OnProcessSpell(object, spell)
	if object == myPlayer then
		if spell.name:lower():find("attack") then			
			lastAttack = GetTickCount() - GetLatency() / 2
			lastWindUpTime = spell.windUpTime * 1000
			lastAttackCD = spell.animationTime * 1000			
			--CanUseQ = true
		end 
	end

	if spell.name == "RivenTriCleave" then          
        if ValidTarget(Target) then
        local movePos = Target + (Vector(myPlayer) - Target):normalized()*(GetDistance(Target)+25)
            if movePos then
                Packet('S_MOVE', {x = movePos.x, y = movePos.z}):send()
            end
    	else
    		Packet('S_MOVE', {x = mousePos.x, y = mousePos.z}):send()
    	end
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

function heroCanMove()
	return ( GetTickCount() + GetLatency() / 2 > lastAttack + lastWindUpTime + 20 )
end 
 
function timeToShoot()
	return aaboost or GetTickCount() + GetLatency() / 2 > lastAttack + lastAttackCD
end 
 
function moveToCursor()
	if GetDistance(mousePos) > 1 then
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

function OnSendPacket(p)
	if p.header == Packet.headers.S_CAST then
		local decodedPacket = Packet(p)
		if decodedPacket:get('spellId') == _Q then Emote() end
	end
end

function Emote()
	p = CLoLPacket(0x47)
	p:EncodeF(myHero.networkID)
	p:Encode1(2)
	p.dwArg1 = 1
	p.dwArg2 = 0
	SendPacket(p)
end

function OnTick()
	Ts:update()
	Target = Ts.target
	if menu.key then
		--Packet('S_CAST', { spellId = _Q, x = mousePos.x, y = mousePos.z }):send()
		--CastSpell(_Q, mousePos.x, mousePos.z)
		CastQ(Target)
		_OrbWalk(Target)
		--if not CanUseQ then TryAttack(Target) end
	end
	
end
