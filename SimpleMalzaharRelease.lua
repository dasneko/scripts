local version = "0.610" 

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

if myHero.charName ~= "Malzahar" and not VIP_USER then return end

require "VPrediction"

function OnLoad()
	Variaveis()
	Menu1()
	OnDraw()
	PrintChat("-[ <font color='#000FFF'> -- Malzahar by Jus loaded !Good Luck! -- </font> ]-")
end

function Menu1()
Menu = scriptConfig(myHero.charName.." by Jus", "Menu")
Menu:addParam("LigarScript", "Global ON/OFF", SCRIPT_PARAM_ONOFF, true)
Menu:addParam("VersaoInfo", "Version", SCRIPT_PARAM_INFO, "0.610")
	Menu:addSubMenu("Combo System", "Combo")
		Menu.Combo:addParam("ComboSystem", "Use Combo System", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Combo:addParam("UseQ", "Use "..myHero:GetSpellData(_Q).name.." (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("UseW", "Use "..myHero:GetSpellData(_W).name.." (W)", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("UseE", "Use "..myHero:GetSpellData(_E).name.." (E)", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("UseR", "Use "..myHero:GetSpellData(_R).name.." (R)", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Combo:addParam("UseIgnite", "Start with Ignite", SCRIPT_PARAM_ONOFF, true)
		--Menu.Combo:addParam("UltimateProtection", "Ultimate Overkill Protection", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("ComboKey", "Team Fight Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu:addSubMenu("Auto Harass System", "Harass")
		Menu.Harass:addParam("HarassSystem", "Use Auto Harass System", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Harass:addParam("UseQ", "Use "..myHero:GetSpellData(_Q).name.." (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("UseW", "Use "..myHero:GetSpellData(_W).name.." (W)", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("UseE", "Use "..myHero:GetSpellData(_E).name.." (E)", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Harass:addParam("ParaComRecall", "Stop if Recall", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("ParaComManaBaixa", "Stop Cast if mana below %", SCRIPT_PARAM_SLICE, 40, 10, 80, 0)
	Menu:addSubMenu("Items Helper System", "Items")
		Menu.Items:addParam("ItemsSystem", "Use Items Helper System", SCRIPT_PARAM_ONOFF, true)
		Menu.Items:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Items:addParam("UseDfg", "Auto Deathfire Grasp", SCRIPT_PARAM_ONOFF, true)
		Menu.Items:addParam("UseZhonia", "Auto Zhonias", SCRIPT_PARAM_ONOFF, true)
		Menu.Items:addParam("ZhoniaPorcentagem", "Zhonias Missing Health %", SCRIPT_PARAM_SLICE, 20, 10, 80, -1)
		Menu.Items:addParam("ZhoniaCC", "Use Zhonias if Hard CC and low health", SCRIPT_PARAM_ONOFF, true)
		Menu.Items:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Items:addParam("UseBarreira", "Auto Barrier", SCRIPT_PARAM_ONOFF, true)
		Menu.Items:addParam("BarreiraPorcentagem", "Barrier Missing Health %", SCRIPT_PARAM_SLICE, 30, 10, 80, -1)
		Menu.Items:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Items:addParam("AutoHP", "Auto HP Potion", SCRIPT_PARAM_ONOFF, true)
		Menu.Items:addParam("AutoHPPorcentagem", "Use HP Potion if health %", SCRIPT_PARAM_SLICE, 60, 20, 80, -1)
		--Menu.items:addParam("AutoMANA", "Auto Mana Potion", SCRIPT_PARAM_ONOFF, true)
		--Menu.items:addParam("AutoMANAPorcentagem", "Use MANA Potion if mana %", SCRIPT_PARAM_SLICE, 30, 10, 80, -1)
	Menu:addSubMenu("Draw System", "Paint")
		Menu.Paint:addParam("DrawSystem", "Use Draw System", SCRIPT_PARAM_ONOFF, true)
		Menu.Paint:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Paint:addParam("PaintQ", "Draw "..myHero:GetSpellData(_Q).name.." (Q) Range", SCRIPT_PARAM_ONOFF, true)
		Menu.Paint:addParam("PaintW", "Draw "..myHero:GetSpellData(_W).name.." (W) Range", SCRIPT_PARAM_ONOFF, false)
		Menu.Paint:addParam("PaintE", "Draw "..myHero:GetSpellData(_E).name.." (E) Range", SCRIPT_PARAM_ONOFF, true)
		Menu.Paint:addParam("PaintR", "Draw "..myHero:GetSpellData(_R).name.." (R) Range", SCRIPT_PARAM_ONOFF, false)
		Menu.Paint:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Paint:addParam("PaintAA", "Draw Auto Attack Range", SCRIPT_PARAM_ONOFF, false)
		Menu.Paint:addParam("PaintMinion", "Minion Last Hit Indicator", SCRIPT_PARAM_ONOFF, true)
		Menu.Paint:addParam("PaintTurrent", "Turrent Last Hit Indicator", SCRIPT_PARAM_ONOFF, true)
		Menu.Paint:addParam("PaintTarget", "Target Circle Indicator", SCRIPT_PARAM_ONOFF, true)
		Menu.Paint:addParam("PaintTarget2", "Target Text Indicator", SCRIPT_PARAM_ONOFF, false)
		Menu.Paint:addParam("PaintMana", "Low Mana Indicator (Blue Circle)", SCRIPT_PARAM_ONOFF, true)
		Menu.Paint:addParam("PaintPassive", "Passive Indicator (White Circle)", SCRIPT_PARAM_ONOFF, true)
		Menu.Paint:addParam("PaintFlash", "Flash Range", SCRIPT_PARAM_ONOFF, false)
	Menu:addSubMenu("General System", "General")
		Menu.General:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.General:addParam("LevelSkill", "Auto Level Skills R-E-W-Q", SCRIPT_PARAM_ONOFF, true)
		Menu.General:addParam("FarmESkill", "Auto E to Farm", SCRIPT_PARAM_ONOFF, true)
		Menu.General:addParam("UseOrb", "Use Orbwalking", SCRIPT_PARAM_ONOFF, true)
		Menu.General:addParam("MoveToMouse", "Only Move to Mouse Position", SCRIPT_PARAM_ONOFF, false)
		Menu.General:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.General:addParam("UsePacket", "Use Packet to Cast", SCRIPT_PARAM_ONOFF, true)
		Menu.General:addParam("UseVPred", "Use VPredicion to Cast", SCRIPT_PARAM_ONOFF, true)
		Menu.General:addParam("AutoUpdate", "Auto Update Script On Start", SCRIPT_PARAM_ONOFF, true)
	
	Alvo = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1100, DAMAGE_MAGIC)
	Alvo.name = "Malzahar"
	Menu:addTS(Alvo)	
	
	MinionsInimigos = minionManager(MINION_ENEMY, 1100, myHero, MINION_SORT_HEALTH_ASC)
	
	VP = VPrediction()
end

function Variaveis()
AlZaharCalloftheVoid = {ready = nil, spellSlot = "Q", packetslot = _Q, range = 900, width = 110, speed = math.huge, delay = .48, spellType = "skillShot", hitLineCheck = false}
AlZaharNullZone = {ready = nil, spellSlot = "W", packetslot = _W, range = 800, width = 250, speed = math.huge, delay = .48, spellType = "skillShot", hitLineCheck = false}
AlZaharMaleficVision = {ready = nil, spellSlot = "E", packetslot = _E, range = 650, width = 0, speed = math.huge, delay = .5, spellType = "enemyCast", hitLineCheck = false}
AlZaharNetherGrasp = {ready = nil, spellSlot = "R", packetslot = _R, range = 700, width = 0, speed = math.huge, delay = .5, spellType = "enemyCast", hitLineCheck = false}
IgniteSpell = {spellSlot = "SummonerDot", iSlot = nil, iReady = false, range = 600}
BarreiraSpell = {spellSlot = "SummonerBarrier", bSlot = nil, bReady = false, range = 0}
FlashSpell = {spellSlot = "SummonerFlash", fSlot = nil, fReady = false, range = 400}
DFG = {id = 3128, ready = false, range = 600, slot = nil}
ZHONIA = {id = 3157, ready = false, range = 0, slot = nil}
Hppotion = {id = 2003, ready = false, slot = nil}
--misc
SequenciaHabilidades = {1,3,3,2,3,4,3,2,3,2,4,2,2,1,1,4,1,1} 
TextAlvo = nil
lastAttack = 0
lastWindUpTime = 0
lastAttackCD = 0 
Recalling = false
PassiveTracked = false
UsingHP = false
end

function AtualizarVariaveis()
	if myHero.dead then return end	
	
	AlZaharCalloftheVoid.ready = (myHero:CanUseSpell(AlZaharCalloftheVoid.packetslot) == READY)
	AlZaharNullZone.ready = (myHero:CanUseSpell(AlZaharNullZone.packetslot) == READY)
	AlZaharMaleficVision.ready = (myHero:CanUseSpell(AlZaharMaleficVision.packetslot) == READY)
	AlZaharNetherGrasp.ready = (myHero:CanUseSpell(AlZaharNetherGrasp.packetslot) == READY)
	
	if myHero:GetSpellData(SUMMONER_1).name:find(IgniteSpell.spellSlot) then IgniteSpell.iSlot = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find(IgniteSpell.spellSlot) then IgniteSpell.iSlot = SUMMONER_2 end
	--if IgniteSpell.iSlot ~= nil then Menu.Combo.UseIgnite = true else Menu.Combo.UseIgnite = false end
	IgniteSpell.iReady = (IgniteSpell.iSlot ~= nil and myHero:CanUseSpell(IgniteSpell.iSlot) == READY)	
	if myHero:GetSpellData(SUMMONER_1).name:find(BarreiraSpell.spellSlot) then BarreiraSpell.bSlot = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find(BarreiraSpell.spellSlot) then BarreiraSpell.bSlot = SUMMONER_2 end
	BarreiraSpell.bReady = (BarreiraSpell.bSlot ~= nil and myHero:CanUseSpell(BarreiraSpell.bSlot) == READY)
	
	DFG.slot = GetInventorySlotItem(DFG.id)	
	ZHONIA.slot = GetInventorySlotItem(ZHONIA.id)
	Hppotion.slot = GetInventorySlotItem(Hppotion.id)
	
	DFG.ready = (DFG.slot ~= nil and myHero:CanUseSpell(DFG.slot) == READY)
	ZHONIA.ready = (ZHONIA.slot ~= nil and myHero:CanUseSpell(ZHONIA.slot) == READY)
	Hppotion.ready = (Hppotion.slot ~= nil and myHero:CanUseSpell(Hppotion.slot) == READY)	

	if Menu.General.UseOrb then
		Menu.General.MoveToMouse = false
	else
		Menu.General.MoveToMouse = true
	end
	TextoAlvo = CalcularDano()
		
	Alvo:update()
	Target = Alvo.target
	MinionsInimigos:update()
end

function OnDraw()

	if myHero.dead or not Menu.Paint.DrawSystem then return end
	
	if Menu.Paint.PaintQ then
		DrawCircle2(myHero.x, myHero.y, myHero.z, AlZaharCalloftheVoid.range,  ARGB(255, 255, 000, 000))
	end 
	if Menu.Paint.PaintW then
		DrawCircle2(myHero.x, myHero.y, myHero.z, AlZaharNullZone.range,  ARGB(255, 000, 000, 255))
	end 
	if Menu.Paint.PaintE then
		DrawCircle2(myHero.x, myHero.y, myHero.z, AlZaharMaleficVision.range,  ARGB(255, 000, 255, 000))
	end 
	if Menu.Paint.PaintR then
		DrawCircle2(myHero.x, myHero.y, myHero.z, AlZaharNetherGrasp.range,  ARGB(255, 255, 255, 000))
	end 
	if Menu.Paint.PaintFlash then
		DrawCircle2(myHero.x, myHero.y, myHero.z, IgniteSpell.range, ARGB(255, 000, 000, 255))
	end 
	if Menu.Paint.PaintAA then
		DrawCircle2(myHero.x, myHero.y, myHero.z, 550, ARGB(255,255,255,255))
	end
	if Menu.Paint.PaintMana and ManaBaixa() then
		--for i=0, 4 do
		DrawCircle2(myHero.x, myHero.y, myHero.z, 35, ARGB(255, 000, 000, 255))
		--end
	end
	if Menu.Paint.PaintTarget then
		if Target ~= nil and not Target.dead then
			--for _, enemy in pairs(GetEnemyHeroes()) do
				if ValidTarget(Target, 1100) then    
					local pos= WorldToScreen(D3DXVECTOR3(Target.x, Target.y, Target.z))
					local posX = pos.x - 35
					local posY = pos.y - 50
					local posZ = pos.z	 	 
						for i=0, 4 do
							DrawCircle2(Target.x, Target.y, Target.z, 60 + i*1.5, ARGB(255, 255, 000, 255))	
						end
				end 
		end
	end
	if Menu.Paint.PaintTarget2 then  
		if Target ~= nil and not Target.dead then
			--for _, enemy in pairs(GetEnemyHeroes()) do
				if ValidTarget(Target, 1100) then  
					DrawText3D(tostring(TextoAlvo), Target.x, Target.y , Target.z, 16, ARGB(255, 255, 000, 255), true)
				end
			--end
		end
	end
	if Menu.Paint.PaintMinion then
		if MinionsInimigos ~= nil then
			for i, Minion in pairs(MinionsInimigos.objects) do
				if Minion ~= nil and not Minion.dead then
					if ValidTarget(Minion, 1100) and Minion.health <= getDmg("AD", Minion, myHero) + 2 then
						DrawCircle2(Minion.pos.x, Minion.pos.y, Minion.pos.z, 85, ARGB(255, 255, 255, 000))
					end
				end
			end
		end    
	end
	if Menu.Paint.PaintTurrent then
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
	if Menu.Paint.PaintPassive then
		if PassiveTracked then			
			DrawCircle2(myHero.x, myHero.y, myHero.z, 65, ARGB(255,255,255,255))
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

function NormalCast(SReady, Skill, Range, Enemy) --_E/_R
	if Enemy ~= nil and ValidTarget(Enemy) then
		if not Menu.General.UseVPred and not Menu.General.UsePacket then
			if SReady and GetDistance(Enemy) <= Range and ValidTarget(Enemy, Range) and not usingUlt then
				CastSpell(Skill, Enemy)
			end
		end 
		if Menu.General.UseVPred or Menu.General.UsePacket then
			if SReady and GetDistance(Enemy) <= Range and ValidTarget(Enemy, Range) and not usingUlt then
				Packet('S_CAST', { spellId = Skill, targetNetworkId = Enemy.networkID }):send() 
			end
		end
	end
end

function NormalCastAreaShot(SReady, Skill, Range, Enemy) --_Q/_W
	if Enemy ~= nil and ValidTarget(Enemy) then
		if not Menu.General.UseVPred and not Menu.General.UsePacket then
			if SReady and GetDistance(Enemy) <= Range and ValidTarget(Enemy, Range) and not usingUlt then
				CastSpell(Skill, Enemy.x, Enemy.z)
			end
		end
 
		if Menu.General.UseVPred or Menu.General.UsePacket then
			if Skill == _Q then
				if SReady and GetDistance(Enemy) <= Range and ValidTarget(Enemy, Range) and not usingUlt then
					local CastPosition, HitChance, Position = VP:GetLineCastPosition(Enemy, AlZaharCalloftheVoid.delay, AlZaharCalloftheVoid.width, Range, 1600, myHero, false)   
						if HitChance >= 2  then
							CastSpell(Skill, CastPosition.x, CastPosition.z)
						end 
				end
			else
  
			if Skill == _W then
				if SReady and GetDistance(Enemy) <= Range and ValidTarget(Enemy, Range) and not usingUlt then
					local AOECastPosition, MainTargetHitChance, nTargets = VP:GetCircularAOECastPosition(Enemy, AlZaharNullZone.delay, AlZaharNullZone.width, Range, 20, myHero) 
						if CountEnemyHeroInRange(Range, myHero) >= 3 then
							if MainTargetHitChance >= 1 then
								CastSpell(_W, AOECastPosition.x , AOECastPosition.z)
							end
						end
						if CountEnemyHeroInRange(Range, myHero) < 3 then
							if MainTargetHitChance >= 2 then
								CastSpell(_W, AOECastPosition.x , AOECastPosition.z)
							end
						end
				end
			end	
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
		  myHero:MoveTo(moveToPos.x, moveToPos.z)	    
    end        
end

function OnProcessSpell(object,spell)
	if myHero.dead then return end
		
	if object == myHero then
	 --PrintChat(tostring(spell.name))
		if spell.name:lower():find("attack") then
			lastAttack = GetTickCount() - GetLatency()/2
			lastWindUpTime = spell.windUpTime*1000
			lastAttackCD = spell.animationTime*1000
		end
		if spell.name:find("AlZaharNetherGrasp") then
			usingUlt = true
		else
			usingUlt = false
		end		
		if spell.name:find("Recall") then
			Recalling = true
		else
			Recalling = false
		end		
		
	end	
end

function OnRecall(hero, channelTimeInMs)
	if hero.networkID == player.networkID then
		Recalling = true
	end
end

function OnAbortRecall(hero)
	if hero.networkID == player.networkID then
		Recalling = false
	end
end

function OnFinishRecall(hero)
	if hero.networkID == player.networkID then
		Recalling = false
	end
end

function OnGainBuff(unit, buff)
	--if myHero.dead then return end
	if unit == nil or buff == nil then return end
	if unit == myHero then 
	
		if buff.name == "Recall" then
			Recalling = true 
		end		
		if buff.name == "alzaharsummonvoidling" then
		 PassiveTracked = true
		end
		if buff.name == "alzaharnethergraspsound" then
			 usingUlt = true
		end
		if buff.type == 5 or 7 or 19 or 21 or 24 or 28 or 31 then
		 GotCC = true
		end
		if buff.name == "RegenerationPotion" then
			UsingHP = true
		end
	end
end

function OnLoseBuff(unit, buff)
	--if myHero.dead then return end
	if unit == nil or buff == nil then return end
		if unit == myHero then
			if buff.name == "Recall" then
				Recalling = false   
			end 
				if buff.name == "alzaharsummonvoidling" then
					PassiveTracked = false
			end
			if buff.name == "alzaharnethergraspsound" then
			 usingUlt = false
			end
			if buff.type == 5 or 7 or 19 or 21 or 24 or 28 or 29 or 30 or 31 then
				GotCC = false
			end
			if buff.name == "RegenerationPotion" then --FlaskOfCrystalWater
				UsingHP = false
			end
		end  
end

function CalcularDano()
	if not Menu.Paint.PaintTarget2 then return end
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
			if ValidTarget(enemy) and GetDistance(enemy) <= 1100 then
				qDmg = ((AlZaharCalloftheVoid.ready and getDmg("Q", enemy, myHero)) or 0)
				wDmg = ((AlZaharNullZone.ready and getDmg("W", enemy, myHero)) or 0)
				eDmg = ((AlZaharMaleficVision.ready and getDmg("E", enemy, myHero)) or 0)
				rDmg = ((AlZaharNetherGrasp.ready and getDmg("R", enemy, myHero)) or 0)
				dfgDmg = ((DFG.ready and getDmg("DFG", enemy, myHero)) or 0)
				iDmg = ((IgniteSpell.iReady and getDmg("IGNITE", enemy, myHero)) or 0)
					local DanoTotal = 0
		--local ComboMode2 = 0
		--local ComboMode3 = 0
	 				DanoTotal = qDmg + wDmg+ eDmg + rDmg + iDmg + dfgDmg					
		--ComboMode2 = wDmg + eDmg + rDmg + iDmg + dfgDmg
		--ComboMode3 = eDmg + rDmg + iDmg + dfgDmg
					--if enemy.health <= DanoTotal then
					--	TextoAlvo = "Full Combo"
					--end
					if enemy.health <= eDmg + rDmg then
					 return "E+R"
					end
					if enemy.health <= wDmg + rDmg then
						return "W+R"
					end
					if enemy.health <= wDmg + eDmg + rDmg then
						return "W+E+R"
					end
	  --elseif enemy.health <= ComboMode2 then
	   --TextoAlvo = "W+E+R"
	  --elseif enemy.health <= ComboMode3 then
	   --TextoAlvo = "E+R"
					if enemy.health > DanoTotal then
						return "Harass"
					end
			end
	end
end

function UseIgnt()
if Menu.Combo.UseIgnite and usingUlt then return end
if not Menu.Combo.UseIgnite then return end
	if IgniteSpell.iReady and Target ~= nil then
		if Menu.General.UsePacket then
			Packet('S_CAST', { spellId = IgniteSpell.iSlot, targetNetworkId = Target.networkID }):send()
		else
			CastSpell(IgniteSpell.iSlot, Target)
		end
	end
end 

function AutoBarr()
	if not Menu.Items.UseBarreira then return end
	if BarreiraSpell.bReady then
		if myHero.health < myHero.maxHealth * (Menu.Items.BarreiraPorcentagem / 100) then
			if Menu.General.UsePacket then
				Packet('S_CAST', { spellId = BarreiraSpell.bSlot, targetNetworkId = myHero.networkID }):send()
			else
				CastSpell(BarreiraSpell.bSlot)
			end
		end
	end
end

function AutoZhonia()
	if not Menu.Items.UseZhonia then return end
		if ZHONIA.ready and not usingUlt then
			if myHero.health < myHero.maxHealth * (Menu.Items.ZhoniaPorcentagem / 100) then
				if Menu.General.UsePacket then
					Packet('S_CAST', { spellId = ZHONIA.slot, targetNetworkId = myHero.networkID }):send()
				else
					CastSpell(ZHONIA.slot)
				end
			end
		end
end

function ZhoniaCC()
	if not Menu.Items.ZhoniaCC then return end
		if ZHONIA.ready and GotCC and myHero.health < myHero.Health * (Menu.Items.ZhoniaPorcentagem /100) then
			if Menu.General.UsePacket then
				Packet('S_CAST', { spellId = ZHONIA.slot, targetNetworkId = myHero.networkID }):send()
			else
				CastSpell(ZHONIA.slot)
			end
		end
end

function AutoDFG()
 if not Menu.Items.UseDfg then return end
  if DFG.ready and Target ~= nil and GetDistance(Target) <= DFG.range and not usingUlt then
   if Menu.General.UsePacket then
    Packet('S_CAST', { spellId = DFG.slot, targetNetworkId = Target.networkID }):send()
   else   
    CastSpell(DFG.slot, Target)
   end
  end
end

function ManaBaixa()
 if myHero.mana < (myHero.maxMana * ( Menu.Harass.ParaComManaBaixa / 100)) then
  return true
 else
  return false
 end
end

function AutoVidaBaixa()
	if not Menu.Items.AutoHP then return end
	if UsingHP then return end
	if myHero.health < (myHero.maxHealth * ( Menu.Items.AutoHPPorcentagem / 100)) then
		if Hppotion.ready then
			CastSpell(Hppotion.slot)
		end
	end
end

function AutoSkillLevel()
if not Menu.General.LevelSkill then return end
 if myHero:GetSpellData(_Q).level + myHero:GetSpellData(_W).level + myHero:GetSpellData(_E).level + myHero:GetSpellData(_R).level < myHero.level then
  local spellSlot = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
  local level = { 0, 0, 0, 0 }
   for i = 1, myHero.level, 1 do
    level[SequenciaHabilidades[i]] = level[SequenciaHabilidades[i]] + 1
   end
   for i, v in ipairs({ myHero:GetSpellData(_Q).level, myHero:GetSpellData(_W).level, myHero:GetSpellData(_E).level, myHero:GetSpellData(_R).level }) do
    if v < level[i] then LevelSpell(spellSlot[i]) end
   end
 end
end 

function FarmE()
	if Recalling and ManaBaixa() then return end
	if not Menu.General.FarmESkill then return end	
		local TimeToTheFirstDamageTick  = 0.3
		local EProjectileSpeed = 1400 --The E projectile Speed
		local Edelay = 0.25 + TimeToTheFirstDamageTick -- The E spell delay
			if MinionsInimigos ~= nil then
				for i, Minion in pairs(MinionsInimigos.objects) do
					if Minion ~= nil and not Minion.dead then
						local Healthh = VP:GetPredictedHealth(Minion, Edelay + GetDistance(Minion, myHero) / EProjectileSpeed)
							if Healthh ~= nil and ValidTarget(Minion, 1100) and Healthh <= getDmg("E", Minion, myHero)/5 and AlZaharMaleficVision.ready then
								NormalCast(AlZaharMaleficVision.ready, AlZaharMaleficVision.packetslot, AlZaharMaleficVision.range, Minion)								
							end
					end
				end
			end
end

function FullCombo()
	if not Menu.Combo.ComboSystem then return end
	if myHero.dead then return end
	if Menu.General.UseOrb and not usingUlt then
		--if Target ~= nil then
			OrbWalking(Target)
		elseif not usingUlt then
			moveToCursor()
		end
	--end 
	if Menu.General.MoveToMouse and Menu.General.UseOrb == false and not usingUlt then
		moveToCursor()
	end
	if Target ~= nil and ValidTarget(Target) then
		UseIgnt()	
		AutoDFG()   	
		if Menu.Combo.UseQ then
			NormalCastAreaShot(AlZaharCalloftheVoid.ready, AlZaharCalloftheVoid.packetslot, AlZaharCalloftheVoid.range, Target)
		end
		if Menu.Combo.UseW then
			NormalCastAreaShot(AlZaharNullZone.ready, AlZaharNullZone.packetslot, AlZaharNullZone.range, Target)
		end
		if Menu.Combo.UseE then
			NormalCast(AlZaharMaleficVision.ready, AlZaharMaleficVision.packetslot, AlZaharMaleficVision.range, Target)	
		end
		if Menu.Combo.UseR then 
			if Menu.Combo.UseQ and not AlZaharCalloftheVoid.ready and not usingUlt then
				elseif Menu.Combo.UseW and not AlZaharNullZone.ready and not usingUlt then
					elseif Menu.Combo.UseE and not AlZaharMaleficVision.ready and not usingUlt then	
						--if Target.health < getDmg("E", Target, myHero) then
						NormalCast(AlZaharNetherGrasp.ready, AlZaharNetherGrasp.packetslot, AlZaharNetherGrasp.range, Target)
			end
		end	
	end
end

function FullHarass()
	if ManaBaixa() or usingUlt then return end
	if Target ~= nil and ValidTarget(Target) then
	if Menu.Harass.UseE then
		NormalCast(AlZaharMaleficVision.ready, AlZaharMaleficVision.packetslot, AlZaharMaleficVision.range, Target)
	end 
	if Menu.Harass.UseW then
		NormalCastAreaShot(AlZaharNullZone.ready, AlZaharNullZone.packetslot, AlZaharNullZone.range, Target)
	end
	if Menu.Harass.UseQ then
		NormalCastAreaShot(AlZaharCalloftheVoid.ready, AlZaharCalloftheVoid.packetslot, AlZaharCalloftheVoid.range, Target)
	end
	end
end

function OnTick()
if not Menu.LigarScript then return end

	AtualizarVariaveis()
	--FullHarass()
	if Menu.Items.ItemsSystem then
		AutoBarr()
		AutoZhonia()	
		ZhoniaCC()
		AutoVidaBaixa()
	end
	if Menu.General.LevelSkill then AutoSkillLevel() end
	if Menu.General.FarmESkill then FarmE() end
	
	if Menu.Combo.ComboKey then
		FullCombo()
	end 
	if Menu.Harass.HarassSystem then
			FullHarass()
	end
end
