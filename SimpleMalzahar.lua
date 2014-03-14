-- [[ Simple Malzahar by Jus v0.1 ]]
-- E + Q + W + R = Full Combo

--AUTOUPDATE
local autoupdateenabled = true
local UPDATE_SCRIPT_NAME = "SimpleMalzahar"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Jusbol/scripts/master/SimpleMalzahar.lua"
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

-- / Auto-Update Function / --
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
				DownloadFile(UPDATE_URL.."?nocache"..myHero.charName..os.clock(), UPDATE_FILE_PATH, function () print("<font color=\"#FF0000\"> >> "..UPDATE_SCRIPT_NAME..": successfully updated. Reload (double F9) Please. ("..version.." => "..ServerVersion..")</font>") end)     
			elseif ServerVersion then
				print("<font color=\"#FF0000\"> >> "..UPDATE_SCRIPT_NAME..": You have got the latest version: <b>"..ServerVersion.."</b></font>")
			end		
			ServerData = nil
		end
	end
	AddTickCallback(update)
end
--AUTOUPDATE END

if myHero.charName ~= "Malzahar" then return end

local version = "0.1"

require "VPrediction"

function OnLoad()
 Menu()
 Variaveis()
 OnDraw()
 PrintChat("-[ <font color='#000FFF'> -|- Malzahar by Jus -|- </font> ]-")
end

function Menu()
JMenu = scriptConfig(myHero.charName.." by Jus", "Jus")
JMenu:addParam("ligado", "Global ON/OFF", SCRIPT_PARAM_ONOFF, true)
JMenu:addParam("orbW", "OrbWalk Key", SCRIPT_PARAM_ONKEYDOWN, false, 74) 

		JMenu:addSubMenu("Combo Settings", "cfg")				
			JMenu.cfg:addParam("QCombo", "Use Q Combo", SCRIPT_PARAM_ONOFF, true)
			JMenu.cfg:addParam("WCombo", "Use W Combo", SCRIPT_PARAM_ONOFF, true)	
			JMenu.cfg:addParam("ECombo", "Use E Combo", SCRIPT_PARAM_ONOFF, true)
			JMenu.cfg:addParam("RCombo", "Use R Commbo", SCRIPT_PARAM_ONOFF, true)
		    --JMenu.cfg:addParam("UIgnite", "Use Ignite", SCRIPT_PARAM_ONOFF, false)
			JMenu.cfg:addParam("CKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
			
		JMenu:addSubMenu("Harass Spell Settings", "harass")
			JMenu.harass:addParam("Qharass", "Use Q Harass", SCRIPT_PARAM_ONOFF, false)
			JMenu.harass:addParam("Wharras", "Use W Harass", SCRIPT_PARAM_ONOFF, false)
			JMenu.harass:addParam("Eharras", "Use E Harass", SCRIPT_PARAM_ONOFF, true)
			
		JMenu:addSubMenu("Draw Settings", "paint")
			JMenu.paint:addParam("Qpaint", "Draw Q Range", SCRIPT_PARAM_ONOFF, false)
			JMenu.paint:addParam("Wpaint", "Draw W Range", SCRIPT_PARAM_ONOFF, false)
			JMenu.paint:addParam("Epaint", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
			JMenu.paint:addParam("Rpaint", "Draw R Range", SCRIPT_PARAM_ONOFF, false)
		
		JMenu:addSubMenu("Target Mode", "trgt")	
		
	Alvo = TargetSelector(TARGET_LESS_CAST_PRIORITY, 900, DAMAGE_MAGIC)
	JMenu.trgt:addTS(Alvo)
	
end

function OnDraw()
 if JMenu.paint.Qpaint then
  DrawCircle(myHero.x, myHero.y, myHero.z, 900, 0xFFFFFF00)
 end 
 if JMenu.paint.Wpaint then
  DrawCircle(myHero.x, myHero.y, myHero.z, 800, 0xFFFFFF00)
 end 
 if JMenu.paint.Epaint then
  DrawCircle(myHero.x, myHero.y, myHero.z, 650, 0xFFFFFF00)
 end 
 if JMenu.paint.Rpaint then
  DrawCircle(myHero.x, myHero.y, myHero.z, 700, 0xFFFFFF00)
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
Ulted = 0
end

function Verificar()
	qReady = (myHero:CanUseSpell(_Q) == READY) or (myHero:GetSpellData(_Q).currentCd < 1)
    wReady = (myHero:CanUseSpell(_W) == READY) or (myHero:GetSpellData(_W).currentCd < 1)
    eReady = (myHero:CanUseSpell(_E) == READY) or (myHero:GetSpellData(_E).currentCd < 1)
    rReady = (myHero:CanUseSpell(_R) == READY) or (myHero:GetSpellData(_R).currentCd < 1) 	
	Alvo:update()
    Target = Alvo.target
end

function OrbWalk(Target)
 if ValidTarget(Target) then
  if GetDistance(Target) <= trueRange() then
   if timeToShoot() and not isChanneling("Spell4") then
     myHero:Attack(Target)
   else
    if heroCanMove() and not isChanneling("Spell4") then
     moveToCursor()
    end
end
   else
  if not isChanneling("Spell4") then
   moveToCursor()
  end
  end
 else
moveToCursor()
end
end
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
function timeToShoot()
        return (GetTickCount() + GetLatency()/2 > lastAttack + lastAttackCD)
end
function heroCanMove()
        return (GetTickCount() + GetLatency()/2 > lastAttack + lastWindUpTime + 20)
end

function moveToCursor()
 if GetDistance(mousePos) > 1 or lastAnimation == "Idle1" then
  local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*300
   myHero:MoveTo(moveToPos.x, moveToPos.z)
 end    
end

function Combo()
if JMenu.cfg.CKey and JMenu.orbW then --orb+combo
if not myHero.dead then
  if Target ~= nil then
   if JMenu.cfg.ECombo and eReady then
    CastE(Target)
   end	   
   if JMenu.cfg.QCombo and qReady then
    CastQ(Target) 
   end	   
   if JMenu.cfg.WCombo and wReady then
    CastW(Target)	
   end	   
   if JMenu.cfg.RCombo and rReady then
    CastR(Target)
   end  
  end
 end  
end
 
if JMenu.cfg.CKey then --combo
 if not myHero.dead then
  if Target ~= nil then
   if JMenu.cfg.ECombo and eReady then
    CastE(Target)
   end 
   if JMenu.cfg.QCombo and qReady then
    CastQ(Target) 
   end
   if JMenu.cfg.WCombo and wReady then
    CastW(Target)	
   end   
   if JMenu.cfg.RCombo and rReady then
    CastR(Target)
   end  
  end
 end 
end
 
if JMenu.orbW then --orb
 OrbWalk(Target)
end 
end

function harrass()
if not myHero.dead then
 if JMenu.orbW then
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

function CastQ(enemy)
if GetDistance(enemy) <= Qrange then CastSpell(_Q, enemy.x, enemy.z) end
end

function CastW(enemy)
if GetDistance(enemy) <= Wrange then CastSpell(_W, enemy.x, enemy.z) end
end

function CastE(enemy)
if GetDistance(enemy) <= Erange then CastSpell(_E, enemy) end
end

function CastR(enemy)
if GetDistance(enemy) <= Rrange then CastSpell(_R, enemy) end
end

function OnTick()
if JMenu.ligado then
 Verificar()
 Combo()
 harrass()
else
 end
end

