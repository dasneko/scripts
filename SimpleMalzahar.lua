local version = "0.1"

--   _____ _                 _               
--  / ____(_)               | |              
-- | (___  _ _ __ ___  _ __ | | ___          
--  \___ \| | '_ ` _ \| '_ \| |/ _ \         
--  ____) | | | | | | | |_) | |  __/         
-- |_____/|_|_| |_| |_| .__/|_|\___|         
-- |  \/  |     | |   | |  | |               
-- | \  / | __ _| |___|_| _| |__   __ _ _ __ 
-- | |\/| |/ _` | |_  / _` | '_ \ / _` | '__|
-- | |  | | (_| | |/ / (_| | | | | (_| | |   
-- |_|  |_|\__,_|_/___\__,_|_| |_|\__,_|_| 
--
--  _                  _           
-- | |                | |          
-- | |__  _   _       | |_   _ ___ 
-- | '_ \| | | |  _   | | | | / __|
-- | |_) | |_| | | |__| | |_| \__ \
-- |_.__/ \__, |  \____/ \__,_|___/
--         __/ |                   
--        |___/                      

-- Simple Malzahar by Jus v0.1 VIP
-- 1. Orbwalk with auto-attack
-- 2. Combo and auto harass configurable
-- 2.1. Enable and disable what you want to use
-- 3. -
-- 3.1. -
-- 4. Draw with lag free
-- 4.1. Enable or disable all skills
-- 5. VPredicition Q and W
-- 5.1. Working to make it better
-- 6. Minion last hit indicator
-- 6.1. Yellow circle to help last hit
-- 7. Turrent hits to kill
-- 7.1.Good to push, base - AD damage
-- 8. Draw Current Target
-- 9. Mana alert (blue circle)
-- 10. Auto Barrier/Zhonias
-- 10.1. Enable or disable
-- 10.2. Health % configurable
-- 11. Auto ignite
-- 11.1. Combo and KS mode
-- 12. Auto E to farm with VPrediction
-- 13. Auto update NOT WORKING

-- Ty to Honda7: Help with E Farm.

-- Encrypt here until the end. Encrypt here until the end. Encrypt here until the end.

-----------------------------------------------------AUTOUPDATE
--[[
local autoupdateenabled = true
local UPDATE_SCRIPT_NAME = "SimpleMalzahar"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Jusbol/scripts/master/SimpleMalzahar.lua"
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

local ServerData
if autoupdateenabled then
	GetAsyncWebResult(UPDATE_HOST, UPDATE_PATH, function(d) ServerData = d end)
	function update()
		if ServerData ~= nil then
			local ServerVersion
			local send, tmp, sstart = nil, string.find(ServerData, "local version = \"")
			if sstart then
				send, tmp = string.find(ServerData, "\"", sstart+1)
			end
			if send then
				ServerVersion = tonumber(string.sub(ServerData, sstart+1, send-1))
			end

			if ServerVersion ~= nil and tonumber(ServerVersion) ~= nil and tonumber(ServerVersion) > tonumber(version) then
				DownloadFile(UPDATE_URL.."?nocache"..myHero.charName..os.clock(), UPDATE_FILE_PATH, function () print("<font color=\"#FF0000\"><b>"..UPDATE_SCRIPT_NAME..":</b> successfully updated. Reload (double F9) Please. ("..version.." => "..ServerVersion..")</font>") end)     
			elseif ServerVersion then
				print("<font color=\"#FF0000\"><b>"..UPDATE_SCRIPT_NAME..":</b> You have got the latest version: <u><b>"..ServerVersion.."</b></u></font>")
			end		
			ServerData = nil
		end
	end
	AddTickCallback(update)
end
]]
------------------------------------------------------AUTOUPDATE END

------------------------------------------------------HEAD

if myHero.charName ~= "Malzahar" or not VIP_USER then return end

require "VPrediction"

local VP = nil

function OnLoad()
 Menu()
 Variaveis()
 OnDraw()
 PrintChat("-[ <font color='#000FFF'> -- Malzahar by Jus loaded !Good Luck! -- </font> ]-")
end

-----------------------------------------------------END HEAD

-----------------------------------------------------MENU

function Menu()
JMenu = scriptConfig(myHero.charName.." by Jus", "Jus")
JMenu:addParam("ligado", "Global ON/OFF", SCRIPT_PARAM_ONOFF, true)
JMenu:addParam("ver", "Version", SCRIPT_PARAM_INFO, version)

		JMenu:addSubMenu("Combo Settings", "cfg")				
			JMenu.cfg:addParam("QCombo", "Use Q Combo", SCRIPT_PARAM_ONOFF, true)
			JMenu.cfg:addParam("WCombo", "Use W Combo", SCRIPT_PARAM_ONOFF, true)	
			JMenu.cfg:addParam("ECombo", "Use E Combo", SCRIPT_PARAM_ONOFF, true)
			JMenu.cfg:addParam("RCombo", "Use R Commbo", SCRIPT_PARAM_ONOFF, true)
		    JMenu.cfg:addParam("UIgnite", "Use Ignite", SCRIPT_PARAM_ONOFF, false)
			JMenu.cfg:addParam("CKey", "Combo/team fight Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
			--JMenu.cfg:addParam("fUlt", "Flash to Combo", SCRIPT_PARAM_ONKEYDOWN, false, 42)	
			
		JMenu:addSubMenu("Auto Harass Settings", "harass")
			JMenu.harass:addParam("Qharass", "Use Q Harass", SCRIPT_PARAM_ONOFF, false)
			JMenu.harass:addParam("Wharras", "Use W Harass", SCRIPT_PARAM_ONOFF, false)
			JMenu.harass:addParam("Eharras", "Use E Harass", SCRIPT_PARAM_ONOFF, true)
			JMenu.harass:addParam("autoh", "Auto Harass ON/OFF", SCRIPT_PARAM_ONOFF, true) 
			
		JMenu:addSubMenu("Draw Settings", "paint")
			JMenu.paint:addParam("SkillInfo", "Draw Skills Range", SCRIPT_PARAM_INFO, "---")
			JMenu.paint:addParam("Qpaint", "Draw Q Range", SCRIPT_PARAM_ONOFF, false)
			JMenu.paint:addParam("Wpaint", "Draw W Range", SCRIPT_PARAM_ONOFF, false)
			JMenu.paint:addParam("Epaint", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
			JMenu.paint:addParam("Rpaint", "Draw R Range", SCRIPT_PARAM_ONOFF, false)
			JMenu.paint:addParam("MiscDraw", "Misc Draw ", SCRIPT_PARAM_INFO, "---")
			JMenu.paint:addParam("mini", "Minion Indicator", SCRIPT_PARAM_ONOFF, true)
			JMenu.paint:addParam("trt", "Turrent Hits to Kill", SCRIPT_PARAM_ONOFF, true)
			JMenu.paint:addParam("dTgt", "Draw Current Target", SCRIPT_PARAM_ONOFF, false)
			JMenu.paint:addParam("flashh", "Draw Flash Range", SCRIPT_PARAM_ONOFF, false)		

		JMenu:addSubMenu("Itens Helper", "iH")
			JMenu.iH:addParam("barr1", "Auto Barrier ON/OFF", SCRIPT_PARAM_ONOFF, true)
			JMenu.iH:addParam("barr", "Barrier Missing Health %", SCRIPT_PARAM_SLICE, 30, 10, 80, -1)
			JMenu.iH:addParam("zho1", "Auto Zhonias ON/OFF", SCRIPT_PARAM_ONOFF, true)
			JMenu.iH:addParam("zho", "Zhonias Missing Health %", SCRIPT_PARAM_SLICE, 20, 10, 80, -1)
		
		JMenu:addSubMenu("Others", "upt")
			JMenu.upt:addParam("ksIgnt", "KS with ignite", SCRIPT_PARAM_ONOFF, true)				
			JMenu.upt:addParam("aLvl", "Auto Level Skills R-E-Q-W", SCRIPT_PARAM_ONOFF, true)
			JMenu.upt:addParam("eFarm", "Auto E to farm", SCRIPT_PARAM_ONOFF, true)
			JMenu.upt:addParam("mn", "Stop harass/E farm if mana below %", SCRIPT_PARAM_SLICE, 40, 10, 80, 0)
			--JMenu.upt:addParam("up", "Auto Update - Not working sorry", SCRIPT_PARAM_ONOFF, false)
			
		JMenu:addSubMenu("Target Mode", "trgt")
		
	Alvo = TargetSelector(TARGET_LESS_CAST_PRIORITY, 900, DAMAGE_MAGIC)
    Alvo.name = "Choose a"
    enemyMinions = minionManager(MINION_ENEMY, 900, myHero, MINION_SORT_HEALTH_ASC)
	JMenu.trgt:addTS(Alvo)
	JMenu.trgt:addParam("Inf", "LessCastPriority is the best!", SCRIPT_PARAM_INFO, "")
		
VP = VPrediction()	
end

-------------------------------------------------------END MENU

-------------------------------------------------------DRAW

function OnDraw()
if not myHero.dead or JMenu.ligado then

 if JMenu.paint.Qpaint then
  DrawCircle2(myHero.x, myHero.y, myHero.z, 900,  ARGB(255, 255, 000, 000))
 end 
 if JMenu.paint.Wpaint then
  DrawCircle2(myHero.x, myHero.y, myHero.z, 800,  ARGB(255, 000, 000, 255))
 end 
 if JMenu.paint.Epaint then
  DrawCircle2(myHero.x, myHero.y, myHero.z, 650,  ARGB(255, 000, 255, 000))
 end 
 if JMenu.paint.Rpaint then
  DrawCircle2(myHero.x, myHero.y, myHero.z, 700,  ARGB(255, 255, 255, 000))
 end
 if IsMyManaLow() then
  DrawCircle2(myHero.x, myHero.y, myHero.z, 45, ARGB(255, 000, 000, 255))
 end
 
 if JMenu.paint.flashh then
  DrawCircle2(myHero.x, myHero.y, myHero.z, Frange, ARGB(255, 000, 000, 255))
 end 
 
 if JMenu.paint.dTgt then
 if Target ~= nil and not Target.dead then
  for _, enemy in pairs(GetEnemyHeroes()) do
        local pos= WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
        local posX = pos.x - 35
        local posY = pos.y - 50
        DrawText(">TARGET<", 14, posX, posY, ARGB(255,0,255,0))    
    end 
 end
 end
 
 if JMenu.paint.mini then
  if enemyMinions ~= nil then
   for i, Minion in pairs(enemyMinions.objects) do
    if Minion ~= nil and not Minion.dead then
    if ValidTarget(Minion, 1000) and Minion.health <= getDmg("AD", Minion, myHero) + 2 then
	 DrawCircle2(Minion.pos.x, Minion.pos.y, Minion.pos.z, 85, ARGB(255, 255, 255, 000))
    end
	end
   end
  end    
 end

 if JMenu.paint.trt then
  local turrets = GetTurrets();
  local targetTurret = nil;
  local hitsToTurret = 0;
  for i, turret in pairs(turrets) do
   if turret ~= nil and turret.team ~= myHero.team then
    targetTurret = turret.object
    hitsToTurret = round(turret.object.health / getDmg("AD", targetTurret, myHero))
	 if hitsToTurret ~= 0 then
	  local pos= WorldToScreen(D3DXVECTOR3(targetTurret.x, targetTurret.y, targetTurret.z))
	  local posX = pos.x - 35
      local posY = pos.y - 50
        DrawText("Hits: "..hitsToTurret,15,posX ,posY  ,ARGB(255,0,255,0))  
	 end
	end
 end
 end
 
 end 
end 

--Honda7
--[[
function FarmE()	
	local EProjectileSpeed = 1400 --The E projectile Speed 
	local Edelay = 0.50 -- The E spell delay
	if enemyMinions ~= nil then
		for i, Minion in pairs(enemyMinions.objects) do
			if Minion ~= nil and not Minion.dead then
				local Healthh = VP:GetPredictedHealth(Minion, Edelay + GetDistance(Minion, myHero) / EProjectileSpeed)
				if ValidTarget(Minion, 1000) and Healthh <= getDmg("E", Minion, myHero) and eReady then
					CastE(Minion)
				end
			end
		end
	end
end
]]
function FarmE()
if not IsMyManaLow() then 
   local TimeToTheFirstDamageTick  = 0.3
    local EProjectileSpeed = 1400 --The E projectile Speed
    local Edelay = 0.25 + TimeToTheFirstDamageTick -- The E spell delay
    if enemyMinions ~= nil then
        for i, Minion in pairs(enemyMinions.objects) do
            if Minion ~= nil and not Minion.dead then
                local Healthh = VP:GetPredictedHealth(Minion, Edelay + GetDistance(Minion, myHero) / EProjectileSpeed)
                if ValidTarget(Minion, 1000) and Healthh <= getDmg("E", Minion, myHero)/5 and eReady then
                    CastE(Minion)
                end
            end
        end
    end
end
end

function DrawCircle2(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextLvl(x, y, z, radius, 1, color, 75) 
    end
end

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
  quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
  quality = 2 * math.pi / quality
  radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end

-------------------------------------------------------END DRAW

-------------------------------------------------------ORBWALK

function OrbWalking(Target)
if not usingUlt then
	if TimeToAttack() and GetDistance(Target) <= myHero.range + GetDistance(myHero.minBBox) then
		myHero:Attack(Target)
    elseif heroCanMove() then
        moveToCursor()
    end
end
end

function TimeToAttack()
    return (GetTickCount() + GetLatency()/2 > lastAttack + lastAttackCD)
end

function heroCanMove()
	return (GetTickCount() + GetLatency()/2 > lastAttack + lastWindUpTime + 20)
end

function moveToCursor()
	if GetDistance(mousePos) then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*300
		myHero:MoveTo(moveToPos.x, moveToPos.z)
    end        
end

function OnProcessSpell(object,spell)
	if object == myHero then
		if spell.name:lower():find("attack") then
			lastAttack = GetTickCount() - GetLatency()/2
			lastWindUpTime = spell.windUpTime*1000
			lastAttackCD = spell.animationTime*1000
        end
    end
	if object == myHero then
     if spell.name:find("AlZaharNetherGrasp") then
		 usingUlt = true
		else
		 usingUlt = false
	 end
	end
end

function OnAnimation(unit,animationName)
    if unit.isMe and lastAnimation ~= animationName then lastAnimation = animationName end
end

-----------------------------------------------------END ORBWALK

-----------------------------------------------------MISC
--[[
function isChanneling(animationName)
 if lastAnimation == animationName then
  return true
 else
  return false
 end
end

function OnAnimation(unit, animationName)
 if unit.isMe and lastAnimation ~= animationName then
  lastAnimation = animationName
 end
end
]]
function Variaveis()
Qrange = 900
Wrange = 800
Erange = 650
Rrange = 700
Frange = 410
Qmana = {80, 85, 90, 95, 100}
Wmana = {90, 95, 100, 105, 110}
Emana = {60, 75, 90, 105, 120}
Rmana = {150, 150, 150}
Qdelay = 0
Wdelay = 0
qReady, wReady, eReady, rReady, fReady, bReady, iReady, zReady = {false, false, false, false, false, false, false, false}
zhSlot = GetInventorySlotItem(3157)
lastAttack = 0
lastWindUpTime = 0
lastAttackCD = 0 
--Qdamage = {80, 135, 190, 245, 300}
--Qscal = 0.8
--Wdamage = {4, 5, 6, 7, 8} -- + 0.01
TCombo = {_Q, _E, _W, _R}
abilitySequence = {1,3,3,2,3,4,3,1,3,1,4,1,1,2,2,4,2,2}
Flsh = nil
barreira = nil
ignt = nil
usingUlt = false

if myHero:GetSpellData(SUMMONER_1).name:find("SummonerFlash") then
 Flsh = SUMMONER_1
elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerFlash") then
 Flsh = SUMMONER_2
end	

if myHero:GetSpellData(SUMMONER_1).name:find("SummonerBarrier") then
 barreira = SUMMONER_1
else 
 if myHero:GetSpellData(SUMMONER_2).name:find("SummonerBarrier") then
  barreira = SUMMONER_2
 end 
end

if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignt = SUMMONER_1
elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignt = SUMMONER_2
end
end

function round(num) 
 if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function AutoIgntKS()
if iReady then
 local damage = 50 + (20 * myHero.level)
 for i = 1, heroManager.iCount, 1 do
  local hero = heroManager:getHero(i)
   if ValidTarget(hero, 600) and hero.health <= damage then
    return UseIgnt()
   end
  end
end
end

function UseIgnt()
 if iReady then
  CastSpell(ignt, Target)
 end
end 

function AutoBarr()
if bReady then
if myHero.health < myHero.maxHealth * (JMenu.iH.barr / 100) then
  CastSpell(barreira)
end
end
end

function AutoZhonia()
if zReady then
if myHero.health < myHero.maxHealth * (JMenu.iH.zho / 100) then
 CastSpell(zhSlot)
end
end
end

function Verificar()
	qReady = (myHero:CanUseSpell(_Q) == READY) 
    wReady = (myHero:CanUseSpell(_W) == READY) 
    eReady = (myHero:CanUseSpell(_E) == READY) 
    rReady = (myHero:CanUseSpell(_R) == READY)
	zReady = (zhSlot ~= nil and myHero:CanUseSpell(zhSlot) == READY)
	fReady = (Flsh ~= nil and myHero:CanUseSpell(Flsh) == READY)
	bReady = (barreira ~= nil and myHero:CanUseSpell(barreira) == READY)
	iReady = (ignt ~= nil and myHero:CanUseSpell(ignt) ==READY)
	Alvo:update()
    Target = Alvo.target
	enemyMinions:update()
	autoupdateenabled = JMenu.upt.up	
end

function IsMyManaLow()
    if myHero.mana < (myHero.maxMana * ( JMenu.upt.mn / 100)) then
        return true
    else
        return false
    end
end

function levelSkills()
 if myHero:GetSpellData(_Q).level + myHero:GetSpellData(_W).level + myHero:GetSpellData(_E).level + myHero:GetSpellData(_R).level < myHero.level then
  local spellSlot = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
  local level = { 0, 0, 0, 0 }
   for i = 1, myHero.level, 1 do
    level[abilitySequence[i]] = level[abilitySequence[i]] + 1
   end
   for i, v in ipairs({ myHero:GetSpellData(_Q).level, myHero:GetSpellData(_W).level, myHero:GetSpellData(_E).level, myHero:GetSpellData(_R).level }) do
    if v < level[i] then LevelSpell(spellSlot[i]) end
   end
 end
end            
 
function CountEnemies(point, range)
	local ChampCount = 0
    for j = 1, heroManager.iCount, 1 do
        local enemyhero = heroManager:getHero(j)
        if myHero.team ~= enemyhero.team and ValidTarget(enemyhero, rRange+150) then
            if GetDistance(enemyhero, point) <= range then
                ChampCount = ChampCount + 1
            end
        end
    end            
    return ChampCount
end
 
--------------------------------------------------------END MISC

--------------------------------------------------------COMBOS

function Combo()
 --if JMenu.cfg.CKey then
Qdelay = 0.45
Wdelay = 0.4

  if Target ~= nil then
   OrbWalking(Target)
  else
   --if not usingUlt then
    moveToCursor()
   --end 
  end 
  
-- end

 if Target ~= nil then
 
  if JMenu.cfg.UIgnite then
   UseIgnt()
  end  
  if JMenu.cfg.WCombo then
   CastW(Target) 
  end
  if JMenu.cfg.ECombo then  
   CastE(Target)
  end 
  if JMenu.cfg.QCombo then 
   CastQ(Target) 
  end
  if JMenu.cfg.RCombo and not eReady and not wReady and not qReady then
   CastR(Target)    
  end
  
 end
 
end

function harrass()
Qdelay = 0.5
Wdelay = 0.5
if not IsMyManaLow() then 
 if Target ~=nil then
  if JMenu.harass.Qharass then
   CastQ(Target)
  elseif JMenu.harass.Wharass then
   CastW(Target)  
  elseif JMenu.harass.Eharass then
   CastE(Target)
  end
 end 
end  
end
 
function CastQ(enemy)
 if qReady and GetDistance(enemy) <= Qrange and not usingUlt then
  local CastPosition, HitChance, Postion = VP:GetLineCastPosition(enemy, Qdelay, 400, Qrange, 1600, myHero, false)
   if HitChance >= 2 then
    CastSpell(_Q, CastPosition.x, CastPosition.z)
   end 
  end
end

function CastW(enemy)
 if wReady and GetDistance(enemy) <= Wrange and not usingUlt then
  local CastPosition, HitChance, Position = VP:GetCircularCastPosition(enemy, Wdelay, 250, Wrange, 20, myHero) 
   if HitChance >= 2 and GetDistance(CastPosition) < Wrange then
    CastSpell(_W, CastPosition.x, CastPosition.z)
   end 
 end
end

function CastE(enemy)
if eReady and GetDistance(enemy) <= Erange and not usingUlt then CastSpell(_E, enemy) end
end

function CastR(enemy)
if rReady and GetDistance(enemy) <= Rrange and not enemy.dead then CastSpell(_R, enemy) end
end

function CombofUlt()
 if fReady then
  CastSpell(Flsh, mousePos.x, mousePos.z)
  Combo()
 end 
 --else OrbWalking(Target) end
end

------------------------------------------------------END COMBOS

function OnTick()
if JMenu.ligado then
Verificar()

if JMenu.iH.barr1 then AutoBarr() end
if JMenu.iH.zho1 then AutoZhonia() end

 if JMenu.upt.aLvl then
  levelSkills()
 end

 if JMenu.cfg.CKey then
  Combo()
 end 
 
 if JMenu.harass.autoh then
  harrass()
 end
 
 if JMenu.upt.ksIgnt then
  AutoIgntKS()
 end
 
 if JMenu.upt.eFarm and not JMenu.cfg.CKey then
  FarmE()
 end
 
-- if JMenu.cfg.fUlt then
--  CombofUlt()
-- end


else end
 
end

