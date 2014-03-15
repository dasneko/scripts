local version = "0.1"

-- [[ Simple Malzahar by Jus v0.1 ]]
-- Orbwalk - Combo and harass
-- Combo and harass configurable
-- Draw with lag free
-- VPredicition Q and W
-- Minion last hit indicator
-- Mana alert
-- auto-update

-----------------------------------------------------AUTOUPDATE

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
				DownloadFile(UPDATE_URL.."?nocache"..myHero.charName..os.clock(), UPDATE_FILE_PATH, function () PrintChat("<font color=\"#FF0000\"> >> "..UPDATE_SCRIPT_NAME..": successfully updated. Reload (double F9) Please. ("..version.." => "..ServerVersion..")</font>") end)     
			elseif ServerVersion then
				PrintChat("<font color=\"#FF0000\"> >> "..UPDATE_SCRIPT_NAME..": You have got the latest version: <b>"..ServerVersion.."</b></font>")
			end		
			ServerData = nil
		end
	end
	AddTickCallback(update)
end

------------------------------------------------------AUTOUPDATE END

------------------------------------------------------HEAD

if myHero.charName ~= "Malzahar" or not VIP_USER then return end
require "VPrediction"

local VP = nil

function OnLoad()
 --Update()
 Menu()
 Variaveis()
 OnDraw()
 PrintChat("-[ <font color='#000FFF'> -|- Malzahar by Jus -|- </font> ]-")
end

-----------------------------------------------------END HEAD

-----------------------------------------------------MENU

function Menu()
JMenu = scriptConfig(myHero.charName.." by Jus", "Jus")
JMenu:addParam("ligado", "Global ON/OFF", SCRIPT_PARAM_ONOFF, true)
--JMenu:addParam("orbW", "OrbWalk Key", SCRIPT_PARAM_ONKEYDOWN, false, 74) 
JMenu:addParam("ver", "Version", SCRIPT_PARAM_INFO, version)

		JMenu:addSubMenu("Combo Settings", "cfg")				
			JMenu.cfg:addParam("QCombo", "Use Q Combo", SCRIPT_PARAM_ONOFF, true)
			JMenu.cfg:addParam("WCombo", "Use W Combo", SCRIPT_PARAM_ONOFF, true)	
			JMenu.cfg:addParam("ECombo", "Use E Combo", SCRIPT_PARAM_ONOFF, true)
			JMenu.cfg:addParam("RCombo", "Use R Commbo", SCRIPT_PARAM_ONOFF, true)
		    --JMenu.cfg:addParam("UIgnite", "Use Ignite", SCRIPT_PARAM_ONOFF, false)
			JMenu.cfg:addParam("CKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
			
		JMenu:addSubMenu("Harass Settings", "harass")
			JMenu.harass:addParam("Qharass", "Use Q Harass", SCRIPT_PARAM_ONOFF, false)
			JMenu.harass:addParam("Wharras", "Use W Harass", SCRIPT_PARAM_ONOFF, false)
			JMenu.harass:addParam("Eharras", "Use E Harass", SCRIPT_PARAM_ONOFF, true)
			JMenu.harass:addParam("orbW", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, 74) 
			
		JMenu:addSubMenu("Draw Settings", "paint")
			JMenu.paint:addParam("Qpaint", "Draw Q Range", SCRIPT_PARAM_ONOFF, false)
			JMenu.paint:addParam("Wpaint", "Draw W Range", SCRIPT_PARAM_ONOFF, false)
			JMenu.paint:addParam("Epaint", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
			JMenu.paint:addParam("Rpaint", "Draw R Range", SCRIPT_PARAM_ONOFF, false)
		
		JMenu:addSubMenu("Target Mode", "trgt")	
		
		JMenu:addSubMenu("Other", "upt")
			JMenu.upt:addParam("up", "Auto Update", SCRIPT_PARAM_ONOFF, true)
			JMenu.upt:addParam("manaa", "Show Mana", SCRIPT_PARAM_ONOFF, true)
			JMenu.upt:addParam("aa", "Auto Attack OrbWalk", SCRIPT_PARAM_ONOFF, true)
			JMenu.upt:addParam("mini", "Minion Indicator", SCRIPT_PARAM_ONOFF, true)
			
	Alvo = TargetSelector(TARGET_LESS_CAST_PRIORITY, 900, DAMAGE_MAGIC)
	JMenu.trgt:addTS(Alvo)
	enemyMinions = minionManager(MINION_ENEMY, 900, myHero, MINION_SORT_HEALTH_ASC)
	
VP = VPrediction()	
end

-------------------------------------------------------END MENU

-------------------------------------------------------DRAW

function OnDraw()

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
 if JMenu.upt.manaa and false then
  if myHero.mana < ComboManaCost(TheCombo) then
   DrawNoMana()
  end
 end 

 if JMenu.upt.mini then
  if enemyMinions ~= nil then
   for i, Minion in pairs(enemyMinions.objects) do
    if Minion ~= nil and not Minion.dead then
    if ValidTarget(Minion, 1000) and Minion.health < getDmg("AD", Minion, myHero) then
	 DrawCircle2(Minion.pos.x, Minion.pos.y, Minion.pos.z, 85, ARGB(255, 255, 255, 0))
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
function round(num) 
 if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

-------------------------------------------------------END DRAW

-------------------------------------------------------ORBWALK

function OrbWalk()

if ValidTarget(Target) and GetDistance(Target) <= trueRange() then
 if timeToShoot() and JMenu.upt.aa then
   myHero:Attack(Target)
  else
   if heroCanMove()  then
    moveToCursor()
   end
 end
else
moveToCursor() 
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

end

function trueRange()
return myHero.range + GetDistance(myHero.minBBox)
end
 
function heroCanMove()
return (GetTickCount() + GetLatency()/2 > lastAttack + lastWindUpTime + 20)
end
 
function timeToShoot()
return (GetTickCount() + GetLatency()/2 > lastAttack + lastAttackCD)
end
 
function moveToCursor()
if GetDistance(mousePos) > 1 or lastAnimation == "Idle1" then
local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*300
myHero:MoveTo(moveToPos.x, moveToPos.z)
end 
end

-----------------------------------------------------END ORBWALK

-----------------------------------------------------MISC

function isChanneling(animationName)
     if lastAnimation == animationName then
         return true
     else
         return false
     end
end

function OnAnimation(unit, animationName)
     if unit.isMe and lastAnimation ~= animationName then lastAnimation = animationName end
end

function OnCreateObj(obj)      
                if obj~= nil and obj.name:find("AlZaharNetherGrasp_tar.troy") then
                        UltStarted = true
        end    
end
function OnDeleteObj(obj)
        if obj~= nil and obj.name:find("AlZaharNetherGrasp_tar.troy") then
                        UltStarted = false
        end
end

function Variaveis()
Qrange = 900
Wrange = 800
Erange = 650
Rrange = 700
lastAttack = 0
lastWindUpTime = 0
lastAttackCD = 0 
UltStarted = false
--Qdamage = {80, 135, 190, 245, 300}
--Qscal = 0.8
--Wdamage = {4, 5, 6, 7, 8} -- + 0.01
--VP = VPrediction()
Qmana = {80, 85, 90, 95, 100}
Wmana = {90, 95, 100, 105, 110}
Emana = {60, 75, 90, 105, 120}
Rmana = {150, 150, 150}
TheCombo = {_Q, _E, _W, _R}
end

function Verificar()
	qReady = (myHero:CanUseSpell(_Q) == READY) or (myHero:GetSpellData(_Q).currentCd < 1)
    wReady = (myHero:CanUseSpell(_W) == READY) or (myHero:GetSpellData(_W).currentCd < 1)
    eReady = (myHero:CanUseSpell(_E) == READY) or (myHero:GetSpellData(_E).currentCd < 1)
    rReady = (myHero:CanUseSpell(_R) == READY) or (myHero:GetSpellData(_R).currentCd < 1) 	
	Alvo:update()
    Target = Alvo.target
	autoupdateenabled = JMenu.upt.up
	enemyMinions:update()
end

--------------------------------------------------------END MISC

--------------------------------------------------------COMBOS

function Combo()
if JMenu.cfg.CKey and JMenu.harass.orbW then --orb+combo
if not myHero.dead then
  if Target ~= nil then
  
    if JMenu.cfg.QCombo and qReady then
    CastQ(Target) 
   end

   if JMenu.cfg.ECombo and eReady then
    CastE(Target)
   end 
  
   if JMenu.cfg.WCombo and wReady then
    CastW(Target)	
   end 
  
   if JMenu.cfg.RCombo and rReady then
    CastR(Target)
   end    
   
  end
  if not isChanneling("Spell4") then
   OrbWalk(Target)
  else
  end
 end  
end
 
if JMenu.cfg.CKey then --combo
 if not myHero.dead then
  if Target ~= nil then
   
   if JMenu.cfg.QCombo and qReady then
    CastQ(Target) 
   end

   if JMenu.cfg.ECombo and eReady then
    CastE(Target)
   end 
  
   if JMenu.cfg.WCombo and wReady then
    CastW(Target)	
   end 
  
   if JMenu.cfg.RCombo and rReady then
    CastR(Target)
   end 
   
  end
  if not isChanneling("Spell4") then
   OrbWalk(Target)
  else
  end
 end

 
end
 
if JMenu.harass.orbW then --orb
 OrbWalk(Target)
end 
end

function harrass()
if not myHero.dead then
 if JMenu.harass.orbW then
  if Target ~= nil then
  if JMenu.harass.Qharass and qReady then
   CastQ(Target)
  end
  if JMenu.harass.Wharras and wReady then
   CastW(Target)
  end 
  if JMenu.harass.Eharras and eReady then
   CastE(Target)
  end
  end  
 end
end
end

--[[ FREE VERSION
function CastQ(enemy)
if GetDistance(enemy) <= Qrange then CastSpell(_Q, enemy.x, enemy.z) end
end
]]

function CastQ(enemy)
local CastPosition, HitChance, Postion = VP:GetLineCastPosition(enemy, 0.5, 100, Qrange, 1600, myHero, false)
 if HitChance >= 2 and GetDistance(CastPosition) < Qrange then
  CastSpell(_Q, CastPosition.x, CastPosition.z)
 end 
end

--[[ FREE VERSION
function CastW(enemy)
if GetDistance(enemy) <= Wrange then CastSpell(_W, enemy.x, enemy.z) end
end
]]

function CastW(enemy)
local CastPosition, HitChance, Postion = VP:GetCircularCastPosition(enemy, 0.5, 250, Wrange, 20)
 if HitChance >= 2 and GetDistance(CastPosition) < Wrange then
  CastSpell(_W, CastPosition.x, CastPosition.z)
 end 
end

function CastE(enemy)
if GetDistance(enemy) <= Erange then CastSpell(_E, enemy) end
end

function CastR(enemy)
if GetDistance(enemy) <= Rrange then CastSpell(_R, enemy) end
end

------------------------------------------------------END COMBOS

function OnTick()
if JMenu.ligado then
 --Variaveis()
 Verificar()
 Combo()
 harrass()
else
 end
end

