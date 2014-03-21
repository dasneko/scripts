local autoupdateenabled = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Jusbol/scripts/master/SimpleMalzaharRelease.lua"
local UPDATE_FILE_PATH = SCRIPT_PATH.."SimpleMalzaharRelease.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

local ServerData
if autoupdateenabled then
	GetAsyncWebResult(UPDATE_HOST, UPDATE_PATH.."?rand="..math.random(1,1000), function(d) ServerData = d end)
	function update()
		if ServerData ~= nil then
			local ServerVersion
			local send, tmp, sstart = nil, string.find(ServerData, "local version = \"")
			if sstart then
				send, tmp = string.find(ServerData, "\"", sstart+1)
			end
			if send then
				ServerVersion = string.sub(ServerData, sstart+1, send-1)
			end

			if ServerVersion ~= nil and tonumber(ServerVersion) ~= nil and tonumber(ServerVersion) > tonumber(version) then
				DownloadFile(UPDATE_URL.."?rand="..math.random(1,1000), UPDATE_FILE_PATH, function () print("<font color=\"#FF0000\"><b>Simple Malzahar (reload F9 2x):</b> successfully updated. ("..version.." => "..ServerVersion..")</font>") end)	 
			elseif ServerVersion then
				print("<font color=\"#FF0000\"><b>Simple Malzahar:</b> You have got the latest version: <u><b>"..version.."</b></u></font>")
			end
			ServerData = nil
		end
	end
	AddTickCallback(update)
end

-- Script Start

if myHero.charName ~= "Malzahar" or not VIP_USER then return end

require "VPrediction"

local VP = nil

function OnLoad()
Menu()
Variaveis()
OnDraw()
PrintChat("-[ <font color='#000FFF'> -- Malzahar by Jus loaded !Good Luck! -- </font> ]-")
end

function Menu()
--Menu Principal
JMenu = scriptConfig(myHero.charName.." by Jus", "Menu")
JMenu:addParam("LigarScript", "Global ON/OFF", SCRIPT_PARAM_ONOFF, true)
JMenu:addParam("Versao", "Version", SCRIPT_PARAM_INFO, version)
		--Combo Options
		JMenu:addSubMenu("Combo Settings", "combo") -- OK		
			JMenu.combo:addParam("QCombo", "Use Q Combo", SCRIPT_PARAM_ONOFF, true)
			JMenu.combo:addParam("WCombo", "Use W Combo", SCRIPT_PARAM_ONOFF, true)	
			JMenu.combo:addParam("ECombo", "Use E Combo", SCRIPT_PARAM_ONOFF, true)
			JMenu.combo:addParam("RCombo", "Use R Commbo", SCRIPT_PARAM_ONOFF, true)
		    JMenu.combo:addParam("SIgnite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
			JMenu.combo:addParam("ComboMode", "Combo Mode", SCRIPT_PARAM_SLICE, 1, 1, 7, 0)
			JMenu.combo:addParam("TFkey", "Combo/team fight Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)				
		--Harass Options	
		JMenu:addSubMenu("Auto Harass Settings", "harass") -- OK
			JMenu.harass:addParam("Qharass", "Use Q Harass", SCRIPT_PARAM_ONOFF, true)
			JMenu.harass:addParam("Wharras", "Use W Harass", SCRIPT_PARAM_ONOFF, false)
			JMenu.harass:addParam("Eharras", "Use E Harass", SCRIPT_PARAM_ONOFF, false)
			JMenu.harass:addParam("HarassRecall", "Don't Harass if Recall", SCRIPT_PARAM_ONOFF, true)
			JMenu.harass:addParam("AutoHarass", "Auto Harass ON/OFF", SCRIPT_PARAM_ONOFF, true)
		--Draw Options	
		JMenu:addSubMenu("Draw Settings", "paint") --OK
			JMenu.paint:addParam("SkillInfo", "Draw Skills Range", SCRIPT_PARAM_INFO, "---")
			JMenu.paint:addParam("Qpaint", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
			JMenu.paint:addParam("Wpaint", "Draw W Range", SCRIPT_PARAM_ONOFF, false)
			JMenu.paint:addParam("Epaint", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
			JMenu.paint:addParam("Rpaint", "Draw R Range", SCRIPT_PARAM_ONOFF, false)
			JMenu.paint:addParam("AutoAttackRange", "Auto Attack Range" , SCRIPT_PARAM_ONOFF, false)
			JMenu.paint:addParam("MiscDraw", "Misc Draw", SCRIPT_PARAM_INFO, "---")
			JMenu.paint:addParam("MinionIndicator", "Minion Indicator", SCRIPT_PARAM_ONOFF, true)
			JMenu.paint:addParam("TurrentHitsIndicator", "Turrent Hits to Kill", SCRIPT_PARAM_ONOFF, true)
			JMenu.paint:addParam("TargetIndicator", "Target Circle Indicator", SCRIPT_PARAM_ONOFF, true)
			JMenu.paint:addParam("TargetIndicator2", "Target Text Indicator (Maybe lag)", SCRIPT_PARAM_ONOFF, false)
			JMenu.paint:addParam("DrawFlashRange", "Draw Flash Range", SCRIPT_PARAM_ONOFF, false)
			JMenu.paint:addParam("ManaIndicator", "Mana Indicator", SCRIPT_PARAM_ONOFF, false)
		--Itens Helper
		JMenu:addSubMenu("Items Helper", "itens") --OK
			JMenu.itens:addParam("UseDFG", "Use Deathfire Grasp ON/OFF", SCRIPT_PARAM_ONOFF, true)
			JMenu.itens:addParam("BarreiraONOFF", "Auto Barrier ON/OFF", SCRIPT_PARAM_ONOFF, true)
			JMenu.itens:addParam("BarreiraPorcentagem", "Barrier Missing Health %", SCRIPT_PARAM_SLICE, 30, 10, 80, -1)
			JMenu.itens:addParam("ZhoniaONOFF", "Auto Zhonias ON/OFF", SCRIPT_PARAM_ONOFF, true)
			JMenu.itens:addParam("ZhoniaPorcentagem", "Zhonias Missing Health %", SCRIPT_PARAM_SLICE, 20, 10, 80, -1)
		--Others
		JMenu:addSubMenu("Others", "diversos") --OK
			JMenu.diversos:addParam("InformacaoDiversosGame" , "Gamming", SCRIPT_PARAM_INFO, "---")
			--JMenu.diversos:addParam("KsIgnite", "KS with Ignite", SCRIPT_PARAM_ONOFF, true)				
			JMenu.diversos:addParam("AutoLevel", "Auto Level Skills R-E-W-Q", SCRIPT_PARAM_ONOFF, true)
			JMenu.diversos:addParam("FarmWithE", "Auto E to farm", SCRIPT_PARAM_ONOFF, true)
			JMenu.diversos:addParam("StopHarassPorcentagem", "Stop harass/E farm if mana below %", SCRIPT_PARAM_SLICE, 40, 10, 80, 0)
			JMenu.diversos:addParam("InformacaoDiversos", "System", SCRIPT_PARAM_INFO, "---")
			JMenu.diversos:addParam("UsePacket", "Use Packets", SCRIPT_PARAM_ONOFF, true)
			JMenu.diversos:addParam("UsarVPrediction", "Use VPrediction", SCRIPT_PARAM_ONOFF, true)
			JMenu.diversos:addParam("UsarOrbwalking", "Use Orbwalking with Combo", SCRIPT_PARAM_ONOFF, true)
			JMenu.diversos:addParam("AutoUpdate", "Auto Update", SCRIPT_PARAM_ONOFF, true)		
			
		--Target mode	
		JMenu:addSubMenu("Target Mode", "TargetSelect")
		Alvo = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1100, DAMAGE_MAGIC)
		Alvo.name = "Malzahar"
		JMenu.TargetSelect:addTS(Alvo)	
		JMenu.TargetSelect:addParam("Informacao", "LessCastPriority recommended.", SCRIPT_PARAM_INFO, "---")
		
		MinionsInimigos = minionManager(MINION_ENEMY, 1000, myHero, MINION_SORT_HEALTH_ASC)
		
VP = VPrediction()	
end

function Variaveis()
--skills
Qrange = 900
Wrange = 800
Erange = 650
Rrange = 700
Frange = 410
Qdamage = {80, 135, 190, 245, 300}
Edamage = {80, 140, 200, 260, 320}
Rdamage = {250, 400, 550}
Qmulti = 0.80
Emulti = 0.80
Rmulti = 1.30
Qmana = {80, 85, 90, 95, 100}
Wmana = {90, 95, 100, 105, 110}
Emana = {60, 75, 90, 105, 120}
Rmana = {150, 150, 150}
Qdelay = 0.48
Wdelay = 0.48
qReady, wReady, eReady, rReady, fReady, bReady, iReady, zReady, dfgReady = {false, false, false, false, false, false, false, false, false}
abilitySequence = {1,3,3,2,3,4,3,2,3,2,4,2,2,1,1,4,1,1}
CustomCombo = false
TextoAlvo = nil
ManaPerLvl = nil
--spells
FlashSlot = nil
BarreiraSlot = nil
IgniteSlot = nil
usingUlt = false
Recalling = false
ZhoniaSlot = nil
DFGSlot = nil
--orb
lastAttack = 0
lastWindUpTime = 0
lastAttackCD = 0 
--spells
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerFlash") then FlashSlot  = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerFlash") then FlashSlot  = SUMMONER_2
	end	
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerBarrier") then BarreiraSlot = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerBarrier") then BarreiraSlot = SUMMONER_2
	end
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then IgniteSlot = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then IgniteSlot = SUMMONER_2
	end

	--if TargetHaveBuff("Recall", myhero) then Recalling = true else Recalling = false end
	TextAlvo = nil
end

function Verificar()
    ManaPerLvl = JMenu.diversos.StopHarassPorcentagem
    ZhoniaSlot = GetInventorySlotItem(3157)
	DFGSlot = GetInventorySlotItem(3128)
	qReady = (myHero:CanUseSpell(_Q) == READY) 
    wReady = (myHero:CanUseSpell(_W) == READY) 
    eReady = (myHero:CanUseSpell(_E) == READY) 
    rReady = (myHero:CanUseSpell(_R) == READY)
	fReady = (FlashSlot ~= nil and myHero:CanUseSpell(FlashSlot) == READY)
	bReady = (BarreiraSlot ~= nil and myHero:CanUseSpell(BarreiraSlot) == READY)
	iReady = (IgniteSlot ~= nil and myHero:CanUseSpell(IgniteSlot) ==READY)	
	zReady = (ZhoniaSlot ~= nil and myHero:CanUseSpell(ZhoniaSlot) == READY)
	dfgReady = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)

	if JMenu.combo.ComboMode == 1 then --FULL COMBO
	 JMenu.combo.QCombo = true
	 JMenu.combo.WCombo = true
	 JMenu.combo.ECombo = true
	 JMenu.combo.RCombo = true
	end
	if JMenu.combo.ComboMode == 2 then --W+E+R
	 JMenu.combo.QCombo = false
	 JMenu.combo.WCombo = true
	 JMenu.combo.ECombo = true
	 JMenu.combo.RCombo = true
	end
	if JMenu.combo.ComboMode == 3 then -- E+R
	 JMenu.combo.QCombo = false
	 JMenu.combo.WCombo = false
	 JMenu.combo.ECombo = true
	 JMenu.combo.RCombo = true
	end
	if JMenu.combo.ComboMode == 4 then --Q+W+R
	 JMenu.combo.QCombo = true
	 JMenu.combo.WCombo = true
	 JMenu.combo.ECombo = false
	 JMenu.combo.RCombo = true
	end
	if JMenu.combo.ComboMode == 5 then -- Q+W+E
	 JMenu.combo.QCombo = true
	 JMenu.combo.WCombo = true
	 JMenu.combo.ECombo = true
	 JMenu.combo.RCombo = false
	end
	if JMenu.combo.ComboMode == 6 then -- W+R
	 JMenu.combo.QCombo = false
	 JMenu.combo.WCombo = true
	 JMenu.combo.ECombo = false
	 JMenu.combo.RCombo = true
	end	
	if JMenu.combo.ComboMode == 7 then -- CUSTOM COMBO
	 CustomCombo = true
	else
	 CustomCombo = false
	end	
	 
    if JMenu.diversos.TargetIndicator then	
     CalcularDano()
    end
	--[[
	if JMenu.combo.SIgnite then
	 JMenu.diversos.KsIgnite = false
	 else
	  JMenu.diversos.KsIgnite = true
	end
	
	if JMenu.diversos.KsIgnite then
	 JMenu.combo.SIgnite = false
	 else
	  JMenu.combo.SIgnite = true
	end
	  ]]	
	Alvo:update()
    Target = Alvo.target
	--[[
	if myTarget and myTarget.type == "obj_AI_Hero" then
	 Target = myTarget
	else
	 Target = nil
	end
	]]
	MinionsInimigos:update()
	autoupdateenabled = JMenu.diversos.AutoUpdate
end

function OnDraw()
if myHero.dead then return end

 if JMenu.paint.Qpaint then
  DrawCircle2(myHero.x, myHero.y, myHero.z, Qrange,  ARGB(255, 255, 000, 000))
 end 
 if JMenu.paint.Wpaint then
  DrawCircle2(myHero.x, myHero.y, myHero.z, Wrange,  ARGB(255, 000, 000, 255))
 end 
 if JMenu.paint.Epaint then
  DrawCircle2(myHero.x, myHero.y, myHero.z, Erange,  ARGB(255, 000, 255, 000))
 end 
 if JMenu.paint.Rpaint then
  DrawCircle2(myHero.x, myHero.y, myHero.z, Rrange,  ARGB(255, 255, 255, 000))
 end 
 if JMenu.paint.DrawFlashRange then
  DrawCircle2(myHero.x, myHero.y, myHero.z, Frange, ARGB(255, 000, 000, 255))
 end 
 if JMenu.paint.AutoAttackRange then
  DrawCircle2(myHero.x, myHero.y, myHero.z, 550, ARGB(255,255,255,255))
 end
 
 if JMenu.paint.ManaIndicator and ManaBaixa() then
  DrawCircle2(myHero.x, myHero.y, myHero.z, 45, ARGB(255, 000, 000, 255))
 end
  
 if JMenu.paint.TargetIndicator then
  if Target ~= nil and not Target.dead then
   for _, enemy in pairs(GetEnemyHeroes()) do
    if ValidTarget(enemy, 1100) then    
	 local pos= WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
     local posX = pos.x - 35
     local posY = pos.y - 50
	 local posZ = pos.z	 	 
	 for i=0, 4 do
     DrawCircle2(enemy.x, enemy.y, enemy.z, 60 + i*1.5, ARGB(255, 255, 000, 255))	
	 end
    end 
   end
  end
 end  
 
 if JMenu.paint.TargetIndicator2 then  
  if Target ~= nil and not Target.dead then
   for _, enemy in pairs(GetEnemyHeroes()) do
    if ValidTarget(enemy, 1100) then  
	 DrawText3D(tostring(TextoAlvo), enemy.x, enemy.y , enemy.z, 16, ARGB(255, 255, 000, 255), true)
    end
   end
  end
 end
 
 if JMenu.paint.MinionIndicator then
  if MinionsInimigos ~= nil then
   for i, Minion in pairs(MinionsInimigos.objects) do
    if Minion ~= nil and not Minion.dead then
    if ValidTarget(Minion, 1000) and Minion.health <= getDmg("AD", Minion, myHero) + 2 then
	 DrawCircle2(Minion.pos.x, Minion.pos.y, Minion.pos.z, 85, ARGB(255, 255, 255, 000))
    end
	end
   end
  end    
 end
 
 if JMenu.paint.TurrentHitsIndicator then
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

function AutoIgntKS()
if not JMenu.diversos.KsIgnite then return end
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
 if iReady and Target ~= nil then
  if JMenu.diversos.UsePacket then
   Packet('S_CAST', { spellId = IgniteSlot, targetNetworkId = Target.networkID }):send()
  else
   CastSpell(IgniteSlot, Target)
  end
 end
end 

function AutoBarr()
if not JMenu.itens.BarreiraONOFF then return end
 if bReady then
  if myHero.health < myHero.maxHealth * (JMenu.itens.BarreiraPorcentagem / 100) then
   if JMenu.diversos.UsePacket then
    Packet('S_CAST', { spellId = BarreiraSlot, targetNetworkId = myHero.networkID }):send()
   else
    CastSpell(BarreiraSlot)
   end
  end
 end
end

function AutoZhonia()
if not JMenu.itens.ZhoniaONOFF then return end
 if zReady then
  if myHero.health < myHero.maxHealth * (JMenu.itens.ZhoniaPorcentagem / 100) then
   if JMenu.diversos.UsePacket then
    Packet('S_CAST', { spellId = ZhoniaSlot, targetNetworkId = myHero.networkID }):send()
   else
    CastSpell(ZhoniaSlot)
   end
  end
end
end

function AutoDFG()
 if not JMenu.itens.UseDFG then return end
  if dfgReady and Target ~= nil and GetDistance(Target) <= 600 then
   if JMenu.diversos.UsePacket then
    Packet('S_CAST', { spellId = DFGSlot, targetNetworkId = Target.networkID }):send()
   else   
    CastSpell(DFGSlot, Target)
   end
  end
end

function ManaBaixa()
 if myHero.mana < (myHero.maxMana * ( JMenu.diversos.StopHarassPorcentagem / 100)) then
  return true
 else
  return false
 end
end

function AutoSkillLevel()
if not JMenu.diversos.AutoLevel then return end
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

function FarmE()
if JMenu.harass.HarassRecall and recal then return end
 if ManaBaixa() then return end
    local TimeToTheFirstDamageTick  = 0.3
    local EProjectileSpeed = 1400 --The E projectile Speed
    local Edelay = 0.25 + TimeToTheFirstDamageTick -- The E spell delay
    if MinionsInimigos ~= nil then
        for i, Minion in pairs(MinionsInimigos.objects) do
            if Minion ~= nil and not Minion.dead then
                local Healthh = VP:GetPredictedHealth(Minion, Edelay + GetDistance(Minion, myHero) / EProjectileSpeed)
                if Healthh ~= nil and ValidTarget(Minion, 1000) and Healthh <= getDmg("E", Minion, myHero)/5 and eReady then
                    NormalCast(eReady, _E, Erange, Minion) 
				end
                end
            end
        end
    end

function CalcularDano()
 for i=1, heroManager.iCount do
 local enemy = heroManager:GetHero(i)
	if ValidTarget(enemy) and GetDistance(enemy) <= 1100 then
	 qDmg = ((qReady and getDmg("Q", enemy, myHero)) or 0)
	 wDmg = ((wReady and getDmg("W", enemy, myHero)) or 0)
	 eDmg = ((eReady and getDmg("E", enemy, myHero)) or 0)
	 rDmg = ((rReady and getDmg("R", enemy, myHero)) or 0)
	 dfgDmg = ((dfgReady and getDmg("DFG", enemy, myHero)) or 0)
	 iDmg = ((iReady and getDmg("IGNITE", enemy, myHero)) or 0)
	 local DanoTotal = 0
	 local ComboMode2 = 0
	 local ComboMode3 = 0
	 
	  DanoTotal = qDmg + wDmg+ eDmg + rDmg + iDmg + dfgDmg
	  ComboMode2 = wDmg + eDmg + rDmg + iDmg + dfgDmg
	  ComboMode3 = eDmg + rDmg + iDmg + dfgDmg
	  if enemy.health <= DanoTotal then
	   TextoAlvo = "Full Combo"	  
	  elseif enemy.health <= ComboMode2 then
	   TextoAlvo = "W+E+R"
	  elseif enemy.health <= ComboMode3 then
	   TextoAlvo = "E+R"
	  elseif enemy.health > DanoTotal then
	   TextoAlvo = "Harass"
	  end
	end
 end
end
	
function OrbWalking(Target)
	if Target ~= nil and TimeToAttack() and GetDistance(Target) <= myHero.range + GetDistance(myHero.minBBox) then
		myHero:Attack(Target)
    elseif heroCanMove() then
        moveToCursor()
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
		-- if JMenu.diversos.UsePacket then
		 -- Packet('S_MOVE', { x = moveToPos.x, y = moveToPos.z}):send()
		-- else
		  myHero:MoveTo(moveToPos.x, moveToPos.z)
	    -- end
    end        
end

function OnProcessSpell(object,spell)
if myHero.dead then return end
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
	
		 --if Target ~= nil and not Target.dead then OrbWalking(Target) else moveToCursor() end 
	 end
end
	


function OnGainBuff(unit, buff)
if unit == nil or buff == nil then return end
 if unit == myHero then 
  if buff.name == "Recall" then
   Recalling = true 
  end
 end
end

function OnLoseBuff(unit, buff)
if unit == nil or buff == nil then return end
 if unit == myHero then
  if buff.name == "Recall" then
   Recalling = false   
  end 
 end  
end

--[[
function OnAnimation(unit, animation)
if unit == myHero then
 if animation == "Spell4" then
  usingUlt = true
 else
  usingUlt = false
 end
end
end
]]
--[[
function OnSendPacket(packet)
if usingUlt then
 local packet = Packet(packet) --or packet:get('name') == 'S_CAST' and packet:get('spellId') ~= IgniteSlot
  if packet:get('name') == 'S_MOVE' and packet:get('sourceNetworkId') == myHero.networkID then
   packet:block()			
  end
 end
end
]]
function round(num) 
 if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

-- SKILLS

function NormalCast(SReady, Skill, Range, Enemy) --_E/_R
if Enemy ~= nil then
 if not JMenu.diversos.UsarVPrediction and not JMenu.diversos.UsePacket then
  if SReady and GetDistance(Enemy) <= Range and ValidTarget(Enemy, Range) and not usingUlt then
   CastSpell(Skill, Enemy)
  end
 end 
 if JMenu.diversos.UsarVPrediction or JMenu.diversos.UsePacket then
  if SReady and GetDistance(Enemy) <= Range and ValidTarget(Enemy, Range) and not usingUlt then
   Packet('S_CAST', { spellId = Skill, targetNetworkId = Enemy.networkID }):send() 
  end
 end
end
end

function NormalCastAreaShot(SReady, Skill, Range, Enemy) --_Q/_W
if Enemy ~= nil then
 if not JMenu.diversos.UsarVPrediction and not JMenu.diversos.UsePacket then
  if SReady and GetDistance(Enemy) <= Range and ValidTarget(Enemy, Range) and not usingUlt then
   CastSpell(Skill, Enemy.x, Enemy.z)
  end
 end
 
 if JMenu.diversos.UsarVPrediction or JMenu.diversos.UsePacket then
  if Skill == _Q then
   if SReady and GetDistance(Enemy) <= Range and ValidTarget(Enemy, Range) and not usingUlt then
    local CastPosition, HitChance, Position = VP:GetLineCastPosition(Enemy, Qdelay, 110, Range, 1600, myHero, false)   
     if HitChance >= 2 then
      CastSpell(Skill, CastPosition.x, CastPosition.z)
     end 
   end
  else
   if Skill == _W then
    if SReady and GetDistance(Enemy) <= Range and ValidTarget(Enemy, Range) and not usingUlt then
     local AOECastPosition, MainTargetHitChance, nTargets = VP:GetCircularAOECastPosition(Enemy, Wdelay, 400, Range, 20, myHero) 
      if MainTargetHitChance >= 2 and GetDistance(AOECastPosition) <= Range then
       CastSpell(_W, AOECastPosition.x , AOECastPosition.z)
      end
	end	
   end
  end  
 end
end 
end

function FullCombo()
if JMenu.diversos.UsarOrbwalking and not usingUlt then
 if Target ~= nil and not Target.dead then OrbWalking(Target) else moveToCursor() end
end 

  if JMenu.combo.SIgnite and not usingUlt then
   UseIgnt()
  end
  if not usingUlt then
  AutoDFG()
  end
-- FULL COMBO 
  if JMenu.combo.ComboMode == 1 then
    NormalCastAreaShot(qReady, _Q, Qrange, Target)
	NormalCast(eReady, _E, Erange, Target)
	NormalCastAreaShot(wReady, _W, Wrange, Target)	
	if JMenu.combo.RCombo and not eReady and not wReady and not qReady then
     NormalCast(rReady, _R, Rrange, Target)
    end	
  end

 -- W+E+R 
  if JMenu.combo.ComboMode == 2 then
   NormalCast(eReady, _E, Erange, Target)
   NormalCastAreaShot(wReady, _W, Wrange, Target)
   if JMenu.combo.RCombo and not eReady and not wReady then
     NormalCast(rReady, _R, Rrange, Target)
   end
  end 

 -- E+R 
  if JMenu.combo.ComboMode == 3 then
   NormalCast(eReady, _E, Erange, Target)   
   if JMenu.combo.RCombo and not eReady then
     NormalCast(rReady, _R, Rrange, Target)
   end
  end  

  -- Q+W+R
  if JMenu.combo.ComboMode == 4 then    
	NormalCastAreaShot(wReady, _W, Wrange, Target)
	NormalCastAreaShot(qReady, _Q, Qrange, Target)
	if JMenu.combo.RCombo and not wReady and not qReady then
     NormalCast(rReady, _R, Rrange, Target)
    end
  end 
  
 -- Q+W+E
  if JMenu.combo.ComboMode == 5 then
    NormalCast(eReady, _E, Erange, Target)
	NormalCastAreaShot(wReady, _W, Wrange, Target)
	NormalCastAreaShot(qReady, _Q, Qrange, Target)
  end
 
 -- W+R 
 if JMenu.combo.ComboMode == 6 then
   NormalCastAreaShot(wReady, _W, Wrange, Target)   
   if JMenu.combo.RCombo and not wReady then
     NormalCast(rReady, _R, Rrange, Target)
   end
  end
  
 -- CUSTOM COMBO 
  if JMenu.combo.ComboMode == 7 then
   if JMenu.combo.QCombo then
    NormalCastAreaShot(qReady, _Q, Qrange, Target)
   end
   if JMenu.combo.WCombo then
    NormalCastAreaShot(wReady, _W, Wrange, Target)
   end
   if JMenu.combo.ECombo then
    NormalCast(eReady, _E, Erange, Target)
   end
   if JMenu.combo.RCombo then
     NormalCast(rReady, _R, Rrange, Target)
   end
  end   

end

function FullHarass() 
  if JMenu.combo.ECombo and not usingUlt then
   NormalCast(eReady, _E, Erange, Target)
  end
 
  if JMenu.combo.WCombo and not usingUlt then
   NormalCastAreaShot(wReady, _W, Wrange, Target)
  end

  if JMenu.combo.QCombo and not usingUlt then
   NormalCastAreaShot(qReady, _Q, Qrange, Target)
  end
end

function OnTick()
if not JMenu.LigarScript then return end

Verificar()
--AutoIgntKS()

 if JMenu.paint.TargetIndicator2 then
  CalcularDano()
 end

 if JMenu.combo.TFkey then
  FullCombo()
 end
 
 if JMenu.harass.AutoHarass and not Recalling and not ManaBaixa() and not usingUlt then
  FullHarass()
 end
 
 if JMenu.itens.BarreiraONOFF then
  AutoBarr()
 end
 
 if JMenu.itens.ZhoniaONOFF then
  AutoZhonia()
 end
 
 if JMenu.diversos.FarmWithE and not Recalling and not ManaBaixa() then
  FarmE()
 end
 
 if JMenu.diversos.AutoLevel then
  AutoSkillLevel()
 end
 
end
