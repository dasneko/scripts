if myHero.charName ~= "Darius" or not VIP_USER then return end

------------------- ONLY COMBO WITH ORBWALK
local version "0.1"
local myPlayer	=	GetMyHero()
local Target  	=	nil
local lastAttack      	= 0
local lastWindUpTime  	= 0
local lastAttackCD		= 0  
-------------------
local function MenuCombo()
	menu:addSubMenu("[Combo Settings]", "combo")
	menu.combo:addParam("q", "Use (Q) in Combo", SCRIPT_PARAM_ONOFF, true)
	menu.combo:addParam("w", "Use (W) in Combo", SCRIPT_PARAM_ONOFF, true)
	menu.combo:addParam("e", "Use (E) in Combo", SCRIPT_PARAM_ONOFF, true)
	menu.combo:addParam("r", "Use (R) in Combo", SCRIPT_PARAM_ONOFF, true)
	menu.combo:addParam("key", "Combo key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
end

function OnLoad()
	menu = scriptConfig("Darius by Jus", "DariusJus")
	MenuCombo() -- Combo Settings
end

local function CastQ(myTarget)
	if GetDistance(myTarget) <= 425 then
		CastSpell(_Q)
	end
end

local function CastW(myTarget)
	if GetDistance(myTarget) <= myPlayer.range then
		CastSpell(_W)
	end
end

local function CastE(myTarget)
	if GetDistance(myTarget) <= 540 then
		CastSpell(_E, myTarget.x, myTarget.z)
	end
end

local function CastR(myTarget)
	local rDmg = getDmg("R", myTarget, myPlayer)
	if GetDistance(myTarget) <= 460 and myTarget.health <= rDmg then
		CastSpell(_R, myTarget)
	end
end

function Combo(myTarget)
	if ValidTarget(myTarget) then
		CastQ(myTarget)
		CastW(myTarget)
		CastE(myTarget)
		CastR(myTarget)
	end
	OrbWalk(myTarget)
end

function heroCanMove()
    return ( GetTickCount() + GetLatency() / 2 > lastAttack + lastWindUpTime + 20)
end 
 
function timeToShoot()
    return (GetTickCount() + GetLatency() / 2 > lastAttack + lastAttackCD)
end 

function moveToCursor() 
	if GetDistance(mousePos) >= 260 then
 		local moveToPos = myPlayer + (Vector(mousePos) - myPlayer):normalized()* 260
		myPlayer:MoveTo(moveToPos.x, moveToPos.z)
	end   
end

function OnProcessSpell(unit, spell)
	if unit.isMe then
		if spell.name:lower():find("attack") then 
            --[[orbwalk]]
            lastAttack      = GetTickCount() - GetLatency() / 2
            lastWindUpTime  = spell.windUpTime * 1000
            lastAttackCD    = spell.animationTime * 1000
        end
    end
end

function OrbWalk(myTarget)
    if ValidTarget(myTarget) and GetDistance(myTarget) <= myPlayer.range then
        if timeToShoot() then
            myPlayer:Attack(myTarget)
        elseif heroCanMove() then
            moveToCursor()
        end
    else
        moveToCursor()
    end
end

local function GetMyTarget()
    local selectedTarget  		= GetTarget()
    local Found 			= false    
    local inimigos 			= nil
    local Enemy 			= nil   
    local finalTarget			= nil
    if range_ == 0 then range_ = 850 end

    if ValidTarget(selectedTarget) and selectedTarget.type == myPlayer.type then
    	return selectedTarget
    end

    if not selectedTarget then
        inimigos  = GetEnemyHeroes()
        for i, Enemy in pairs(inimigos) do             	  
            local basedmg   = 100
            local myDmg     = (myPlayer:CalcDamage(Enemy, 200) or 0)            
            if ValidTarget(Enemy) and GetDistance(Enemy) <= 800 then
            	local finalDmg	=	Enemy.health / myDmg
                if finalDmg < basedmg then
                	Found = true                	
                    return Enemy
                end		                
            else
            	Found = false
            end		  
        end
    end
    if not selectedTarget and not Found then
    	local mouseTarget = nil
    	inimigos  = GetEnemyHeroes()
    	for i, Enemy in pairs(inimigos) do
    		local distancMouse = GetDistance(mousePos, Enemy)
	    	if ValidTarget(Enemy) and distancMouse <= 150 then
	    		return Enemy
	    	end
	    end
	end	
	finalTarget = selectedTarget or Enemy
	return finalTarget
end

function OnTick()
	local RealTarget = nil
	local ComboOn	 = menu.combo.key
	Target = GetMyTarget()
    if ValidTarget(Target) and Target.type == myPlayer.type then
    	RealTarget = Target
    end
    if ComboOn then Combo(RealTarget) end
end
