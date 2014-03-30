if myHero.charName ~= "Brand" or not VIP_USER then return end

--[[AUTO UPDATE]]--
local version = "0.1" 
local autoupdateenabled = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Jusbol/scripts/master/SimpleBrandRelease.lua"
local UPDATE_FILE_PATH = SCRIPT_PATH.."SimpleBrandRelease.lua"
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
				DownloadFile(UPDATE_URL.."?rand="..math.random(1,1000), UPDATE_FILE_PATH, function () print("<font color=\"#FF0000\"><b>Brand Zombie Nation (reload F9 2x):</b> successfully updated. ("..version.." => "..ServerVersion..")</font>") end)	 
			elseif ServerVersion then
				print("<font color=\"#FF0000\"><b>Brand Zombie Nation:</b> You have got the latest version: <u><b>"..version.."</b></u></font>")
			end
			ServerData = nil
		end
	end
	AddTickCallback(update)
end
--[[AUTO UPDATE END]]--

--[[SKILLS]]--
local BrandBlaze = {ready = nil, spellSlot = _Q, range = 900, width = 80, speed = 1200,  hitLineCheck = true, delay = 0.5}
local BrandFissure = {ready = nil, spellSlot = _W, range = 900, width = 0, speed = 20, hitLineCheck = false, delay = 0.5}
local BrandConflagration = {ready = nil, spellSlot = _E, range = 625, width = 0, speed = 1800, hitLineCheck = false, delay = 0.5}
local BrandWildfire = {ready = nil, spellSlot = _R, range = 750, width = 0, speed = 1000, hitLineCheck = false, timer = 230 - GetLatency(), delay = 0.5}
--[[SPELLS]]--
local IgniteSpell = {spellSlot = "SummonerDot", iSlot = nil, ready = false, range = 600}
local BarreiraSpell = {spellSlot = "SummonerBarrier", bSlot = nil, ready = false, range = 0}
local FlashSpell = {spellSlot = "SummonerFlash", fSlot = nil, ready = false, range = 400}
--[[ITEMS]]--
local DFG = {id = 3128, ready = false, range = 750, slot = nil}
local ZHONIA = {id = 3157, ready = false, range = 0, slot = nil}
local Seraph = {id = 3040, ready = false, range = 0, slot = nil}
local Hppotion = {id = 2003, ready = false, slot = nil}
local Manapotion = {id = 2004 , ready = false, slot = nil}
--[[ORBWALK]]--
local lastAttack, lastWindUpTime, lastAttackCD = 0, 0, 0
local myTrueRange = 0
--[[MISC]]--
local MeuAlvo = nil
local UsandoHP = false
local UsandoMana = false
local RecebeuCC = false
local UsandoRecall =  false
local AtualizarDanoInimigo = 0
local SequenciaHabilidades1 = {1,3,3,2,3,4,3,2,3,2,4,2,2,1,1,4,1,1} 
local Invulneraveis = { PoppyDiplomaticImmunity, UndyingRage, JudicatorIntervention, VladimirSanguinePool}
--[[VPREDICTION]]--
require "VPrediction"

function OnLoad()
Menu = scriptConfig(myHero.charName.." by Jus", "Brand")
Menu:addParam("LigarScript", "Global ON/OFF", SCRIPT_PARAM_ONOFF, true)
Menu:addParam("VersaoInfo", "Version", SCRIPT_PARAM_INFO, version)
	--[[COMBO]]--
	Menu:addSubMenu("Combo System", "Combo")
		Menu.Combo:addParam("ComboSystem", "Use Combo System", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Combo:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Combo:addParam("UseQ", "Use "..myHero:GetSpellData(_Q).name.." (Q)", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Combo:addParam("UseW", "Use "..myHero:GetSpellData(_W).name.." (W)", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Combo:addParam("UseE", "Use "..myHero:GetSpellData(_E).name.." (E)", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Combo:addParam("UseR", "Use "..myHero:GetSpellData(_R).name.." (R)", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Combo:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Combo:addParam("UseIgnite", "Start with Ignite", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addSubMenu("Ultimate Settings", "Ultimate")
			Menu.Combo.Ultimate:addParam("Untargetable", "Don't R to Invulnerability", SCRIPT_PARAM_ONOFF, true)
			Menu.Combo.Ultimate:addParam("EnemyR", "Only Cast R if enemy with enemy >", SCRIPT_PARAM_SLICE, 0, 0, 4, 0)	
		Menu.Combo:addParam("ComboKey", "Team Fight Key", SCRIPT_PARAM_ONKEYDOWN, false, 32) --OK
	--[[HARASS]]--	
	Menu:addSubMenu("Auto Harass System", "Harass")
		Menu.Harass:addParam("HarassSystem", "Use Auto Harass System", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Harass:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Harass:addParam("AutoHarass", "Automatic Harass", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("UseQ", "Use "..myHero:GetSpellData(_Q).name.." (Q)", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Harass:addParam("UseW", "Use "..myHero:GetSpellData(_W).name.." (W)", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Harass:addParam("UseE", "Use "..myHero:GetSpellData(_E).name.." (E)", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Harass:addParam("", "", SCRIPT_PARAM_INFO, "")		
		Menu.Harass:addParam("ParaComManaBaixa", "Stop Cast if mana below %", SCRIPT_PARAM_SLICE, 40, 10, 80, 0) --OK
		Menu.Harass:addParam("HarassKey", "Manual Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
				--Menu.Harass:addParam("KSWithQ", "Try KS with Q", SCRIPT_PARAM_ONOFF, true)
	--[[FARM]]--
	
	Menu:addSubMenu("Farm Helper System", "Farmerr")
		Menu.Farmerr:addParam("FarmerrSystem", "Use Farm System", SCRIPT_PARAM_ONOFF, true)
		--Menu.Farmerr:addParam("", "", SCRIPT_PARAM_INFO, "")
		--Menu.Farmerr:addParam("FarmESkill", "Auto E to Farm", SCRIPT_PARAM_ONOFF, true)
		Menu.Farmerr:addParam("LastHit", "Last Hit Key (experimental)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
		Menu.Farmerr:addParam("LastHitDelay", "Last Hit Delay", SCRIPT_PARAM_SLICE, 1000, -500, 3000, 1)
		Menu.Farmerr:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Farmerr:addParam("ArcaneON", "Use Arcane Blade Mastery", SCRIPT_PARAM_ONOFF, true)
		Menu.Farmerr:addParam("ButcherON", "Use Butcher Mastery", SCRIPT_PARAM_ONOFF, true)
		
	--[[ITEMS]]--	
	Menu:addSubMenu("Items Helper System", "Items")
		Menu.Items:addParam("ItemsSystem", "Use Items Helper System", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Items:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Items:addParam("UseDfg", "Auto Deathfire Grasp with Combo", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Items:addParam("UseDfgR", "Deathfire Grasp only if R is ready", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Items:addParam("UseDfgRrange", "Deathfire Grasp only in R range", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Items:addParam("UseZhonia", "Auto Zhonias", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Items:addParam("ZhoniaPorcentagem", "Zhonias Missing Health %", SCRIPT_PARAM_SLICE, 20, 10, 80, -1) --OK
		Menu.Items:addParam("UseSeraph", "Auto Seraph's Embrace", SCRIPT_PARAM_ONOFF, true)
		Menu.Items:addParam("SeraphPorcentagem", "Seraph's Embrace Missing Health %", SCRIPT_PARAM_SLICE, 20, 10, 80, -1)
		--Menu.Items:addParam("ZhoniaCC", "Use Zhonias if Hard CC", SCRIPT_PARAM_ONOFF, true) 
		Menu.Items:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Items:addParam("UseBarreira", "Auto Barrier", SCRIPT_PARAM_ONOFF, true) 
		Menu.Items:addParam("BarreiraPorcentagem", "Barrier Missing Health %", SCRIPT_PARAM_SLICE, 30, 10, 80, -1) 
		Menu.Items:addParam("AntiDoubleIgnite", "Anti Double Ignite", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Items:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Items:addParam("AutoHP", "Auto HP Potion", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Items:addParam("AutoHPPorcentagem", "Use HP Potion if health %", SCRIPT_PARAM_SLICE, 60, 20, 80, -1) --OK
		Menu.Items:addParam("AutoMANA", "Auto Mana Potion", SCRIPT_PARAM_ONOFF, true)
		Menu.Items:addParam("AutoMANAPorcentagem", "Use MANA Potion if mana %", SCRIPT_PARAM_SLICE, 30, 10, 80, -1)
	--[[DRAW]]--	
	Menu:addSubMenu("Draw System", "Paint")
		Menu.Paint:addParam("DrawSystem", "Use Draw System", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Paint:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Paint:addParam("PaintQ", "Draw "..myHero:GetSpellData(_Q).name.." (Q) Range", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Paint:addParam("PaintW", "Draw "..myHero:GetSpellData(_W).name.." (W) Range", SCRIPT_PARAM_ONOFF, false) --OK
		Menu.Paint:addParam("PaintE", "Draw "..myHero:GetSpellData(_E).name.." (E) Range", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Paint:addParam("PaintR", "Draw "..myHero:GetSpellData(_R).name.." (R) Range", SCRIPT_PARAM_ONOFF, false) --OK
		Menu.Paint:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Paint:addParam("EnemyDamage", "Current Enemy Damage", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Paint:addParam("PaintAA", "Draw Auto Attack Range", SCRIPT_PARAM_ONOFF, false) --OK
		Menu.Paint:addParam("PaintMinion", "Minion Last Hit Indicator", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Paint:addParam("PaintTurrent", "Turret Last Hit Indicator", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Paint:addParam("PaintTurrentRange", "Enemy Turret Range", SCRIPT_PARAM_ONOFF, false) --OK
		Menu.Paint:addParam("PaintMana", "Low Mana Indicator (Blue Circle)", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Paint:addParam("ManaCheck", "Draw Mana Advice Combo", SCRIPT_PARAM_ONOFF, true)
		Menu.Paint:addParam("PaintPassive", "Passive Indicator (White Circle)", SCRIPT_PARAM_ONOFF, true) --OK	
		Menu.Paint:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Paint:addParam("PredInimigo", "Enemy Moviment Prediction", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.Paint:addParam("PaintTarget", "Target Circle Indicator", SCRIPT_PARAM_ONOFF, true) --OK
		--Menu.Paint:addParam("PaintTarget2", "Target Text Indicator", SCRIPT_PARAM_ONOFF, false) 
	--[[MISC]]--	
	Menu:addSubMenu("General System", "General")		
		Menu.General:addParam("LevelSkill", "Auto Level Skills R-E-W-Q", SCRIPT_PARAM_ONOFF, true) --OK	
		Menu.General:addParam("UseOrb", "Use Orbwalking", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.General:addParam("MoveToMouse", "Only Move to Mouse Position", SCRIPT_PARAM_ONOFF, false) --OK
		Menu.General:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.General:addParam("UsePacket", "Use Packet to Cast", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.General:addParam("UseVPred", "Use VPredicion to Cast", SCRIPT_PARAM_ONOFF, true) --OK
		Menu.General:addParam("SelecionarAlvo", "Target Mode", SCRIPT_PARAM_SLICE, 1, 1, 2, 0) 
		Menu.General:addParam("AutoUpdate", "Auto Update Script On Start", SCRIPT_PARAM_ONOFF, true) --OK
	--[[SPELL SLOT CHECK]]--
		if myHero:GetSpellData(SUMMONER_1).name:find(IgniteSpell.spellSlot) then IgniteSpell.iSlot = SUMMONER_1
			elseif myHero:GetSpellData(SUMMONER_2).name:find(IgniteSpell.spellSlot) then IgniteSpell.iSlot = SUMMONER_2 end	
		if myHero:GetSpellData(SUMMONER_1).name:find(BarreiraSpell.spellSlot) then BarreiraSpell.bSlot = SUMMONER_1
			elseif myHero:GetSpellData(SUMMONER_2).name:find(BarreiraSpell.spellSlot) then BarreiraSpell.bSlot = SUMMONER_2 end	
	--[[MMA/SAC Disable orbwalk]]--
	if _G.MMA_loaded then
		_G.MMA_Orbwalker = false 
	end
	--[[OTHERS]]--		
	MinionsInimigos = minionManager(MINION_ENEMY, 1200, myHero, MINION_SORT_HEALTH_ASC)
	wayPointManager = WayPointManager()
	myTrueRange = myHero.range + GetDistance(myHero.minBBox)
	VP = VPrediction()
	PrintChat("-[ <font color='#000FFF'> -- Brand by Jus loaded !Good Luck! -- </font> ]-")
end
--[[SKILLS]]--
function CastQ()
	local AlvoQ = MelhorAlvo(BrandBlaze.range)
	if AlvoQ ~= nil and not UsandoR then
		if myHero:CanUseSpell(BrandBlaze.spellSlot) == READY then
			if Menu.General.UseVPred then
			local CastPosition, HitChance, Position = VP:GetCircularCastPosition(AlvoQ, (BrandBlaze.delay + 200)/1600, BrandBlaze.width, BrandBlaze.range, math.huge, myHero, true)   
				if HitChance >= 2 then
					CastSpell(BrandBlaze.spellSlot, CastPosition.x, CastPosition.z)
				end 				
			elseif not Menu.General.UsePacket and not Menu.General.UseVPred then
				CastSpell(BrandBlaze.spellSlot, AlvoQ.x, AlvoQ.z)
			end			
		end
	end
end

function CastW()
	local AlvoW = MelhorAlvo(BrandFissure.range)
	if AlvoW ~= nil and not UsandoR then
		if myHero:CanUseSpell(BrandFissure.spellSlot) == READY then
			if Menu.General.UseVPred then
				local AOECastPosition, MainTargetHitChance, nTargets = VP:GetCircularAOECastPosition(AlvoW, BrandFissure.delay, BrandFissure.width, BrandFissure.range, math.huge, myHero) 
					if CountEnemyHeroInRange(Range, myHero) >= 3 then
						if MainTargetHitChance >= 1 then
							CastSpell(BrandFissure.spellSlot, AOECastPosition.x , AOECastPosition.z)
						end
					end
					if CountEnemyHeroInRange(Range, myHero) < 3 then
						if MainTargetHitChance >= 2 then
							CastSpell(BrandFissure.spellSlot, AOECastPosition.x , AOECastPosition.z)
						end
					end
			else CastSpell(BrandFissure.spellSlot, AlvoW.x, AlvoW.z)
			end				
		end
	end
end

function CastE()
	local AlvoE = MelhorAlvo(BrandConflagration.range)
	if AlvoE ~= nil and not UsandoR then
		if myHero:CanUseSpell(BrandConflagration.spellSlot) == READY then
			if Menu.General.UsePacket then
				Packet('S_CAST', { spellId = BrandConflagration.spellSlot, targetNetworkId = AlvoE.networkID }):send()				
			else
				CastSpell(BrandConflagration.spellSlot, AlvoE)				
			end
		end
	end
end

function CastR()
	local AlvoR = MelhorAlvo(BrandWildfire.range)
	if TemImunidade(AlvoR) then return end
	if AlvoR ~= nil and not TemImunidade(AlvoR) then
		if myHero:CanUseSpell(BrandWildfire.spellSlot) == READY then
			if Menu.General.UsePacket then
				Packet('S_CAST', { spellId = BrandWildfire.spellSlot, targetNetworkId = AlvoR.networkID }):send()
			else
				CastSpell(BrandWildfire.spellSlot, AlvoR)
			end		
		end
	end
end

function CastCombo()	
	if Menu.Combo.ComboKey then		
		if not UsandoR and not _G.Evade and Menu.General.UseOrb then _OrbWalk() end
		if Menu.Items.ItemsSystem then
			if Menu.Combo.UseIgnite then CastIgnite() end		
			if Menu.Items.UseDfg then CastDFG() end
		end
		if Menu.Combo.UseW then CastW() end
		if Menu.Combo.UseQ then CastQ() end
		if Menu.Combo.UseE then CastE() end			
		if Menu.Combo.UseR then
			if Menu.Combo.UseQ and Menu.Combo.UseW and Menu.Combo.UseE then			 
				if myHero:CanUseSpell(BrandBlaze.spellSlot) ~= READY and myHero:CanUseSpell(BrandFissure.spellSlot) ~= READY and myHero:CanUseSpell(BrandConflagration.spellSlot) ~= READY then
					CastR()
				end
			end
			if Menu.Combo.UseW and Menu.Combo.UseE and not Menu.Combo.UseQ then
				if myHero:CanUseSpell(BrandFissure.spellSlot) ~= READY and myHero:CanUseSpell(BrandConflagration.spellSlot) ~= READY then
					CastR()
				end
			end
			if Menu.Combo.UseW and not Menu.Combo.UseQ and not Menu.Combo.UseE then
				if myHero:CanUseSpell(BrandFissure.spellSlot) ~= READY then	CastR()	end
			end
			if Menu.Combo.UseE and not Menu.Combo.UseQ and not Menu.Combo.UseW then
				if myHero:CanUseSpell(BrandConflagration.spellSlot) ~= READY then	CastR()	end
			end
			if Menu.Combo.UseQ and not Menu.Combo.UseW and not Menu.Combo.UseE then
				if myHero:CanUseSpell(BrandBlaze.spellSlot) ~= READY then	CastR()	end
			end
		end	
	end
end

function CastHarass()	
		if Menu.Harass.UseW then CastW() end
		if Menu.Harass.UseQ then CastQ() end
		if Menu.Harass.UseE then CastE() end	
end
--[[SKILLS END]]--

--[[SPELLS]]--
function CastIgnite()
	local AlvoI = MelhorAlvo(IgniteSpell.range)
	if IgniteSpell.iSlot ~= nil and myHero:CanUseSpell(IgniteSpell.iSlot) == READY and AlvoI ~= nil then	
		if Menu.Items.AntiDoubleIgnite and TargetHaveBuff("SummonerDot", AlvoI) then return end
		if Menu.Items.AntiDoubleIgnite and not TargetHaveBuff("SummonerDot", AlvoI) then
			if Menu.General.UsePacket then
				Packet('S_CAST', { spellId = IgniteSpell.iSlot, targetNetworkId = AlvoI.networkID }):send()
			else
				CastSpell(IgniteSpell.iSlot, AlvoI)
			end
		else
			if Menu.General.UsePacket then
				Packet('S_CAST', { spellId = IgniteSpell.iSlot, targetNetworkId = AlvoI.networkID }):send()
			else
				CastSpell(IgniteSpell.iSlot, AlvoI)
			end
		end
	end
end 

function CastDFG()
	local AlvoDFG = nil
	if Menu.Items.UseDfgRrange then
		AlvoDFG = MelhorAlvo(BrandWildfire.range)
	else
		AlvoDFG = MelhorAlvo(DFG.range)
	end
		if AlvoDFG ~= nil then
			if DFG.slot ~= nil and myHero:CanUseSpell(DFG.slot) == READY and Menu.Items.UseDfgR and not UsandoR and GetDistance(AlvoDFG) <= BrandWildfire.range then
				if Menu.General.UsePacket then
					Packet('S_CAST', { spellId = DFG.slot, targetNetworkId = AlvoDFG.networkID }):send()
				else
					CastSpell(DFG.slot, Target)
				end
			else
				if Menu.General.UsePacket then
					Packet('S_CAST', { spellId = DFG.slot, targetNetworkId = AlvoDFG.networkID }):send()
				else
					CastSpell(DFG.slot, Target)
				end
			end
		end
end

function CastZhonia()
	local VidaParaUsarZhonia = myHero.maxHealth * (Menu.Items.ZhoniaPorcentagem / 100)
	if myHero.health <= VidaParaUsarZhonia and ZHONIA.slot ~= nil and myHero:CanUseSpell(ZHONIA.slot) == READY and not UsandoR then
		if Menu.General.UsePacket then
			Packet('S_CAST', { spellId = ZHONIA.slot, targetNetworkId = myHero.networkID }):send()
		else
			CastSpell(ZHONIA.slot)
		end
		--[[
	else
		if Menu.Items.ZhoniaCC and RecebeuCC then
			if Menu.General.UsePacket then
				Packet('S_CAST', { spellId = ZHONIA.slot, targetNetworkId = myHero.networkID }):send()
			else
				CastSpell(ZHONIA.slot)
			end
		end
		]]--
	end
end	

function CastBarreira()	
	local VidaParaUsarBarreira = (myHero.maxHealth * (Menu.Items.BarreiraPorcentagem / 100))
	if BarreiraSpell.bSlot ~= nil and myHero:CanUseSpell(BarreiraSpell.bSlot) == READY then	
		if myHero.health <= VidaParaUsarBarreira then
			CastSpell(BarreiraSpell.bSlot)			
		end
	end
end	

function CastHPPotion()
	local VidaParaUsarPotionHP = (myHero.maxHealth * ( Menu.Items.AutoHPPorcentagem / 100))
	if Hppotion.slot ~= nil and myHero:CanUseSpell(Hppotion.slot) == READY and not UsandoHP then
		if myHero.health <= VidaParaUsarPotionHP then
			CastSpell(Hppotion.slot)		
		end
	end
end

function CastManaPotion()
	local ManaParaUsarPotion = (myHero.maxMana * ( Menu.Items.AutoMANAPorcentagem / 100))
	if Manapotion.slot ~= nil and myHero:CanUseSpell(Manapotion.slot) == READY and not UsandoMana then
		if myHero.mana <= ManaParaUsarPotion then
			CastSpell(Manapotion.slot)
		end
	end
end

function CastSeraph()
	local VidaParaUsarSeraph = (myHero.maxHealth * ( Menu.Items.SeraphPorcentagem / 100))
	if Seraph.slot ~= nil and myHero:CanUseSpell(Seraph.slot) == READY then
		if myHero.health <= VidaParaUsarSeraph then
			CastSpell(Seraph.slot)
		end
	end
end

--[[END]]--

--[[OTHER]]--
function AutoSkillLevel()
	if myHero:GetSpellData(_Q).level + myHero:GetSpellData(_W).level + myHero:GetSpellData(_E).level + myHero:GetSpellData(_R).level < myHero.level then
	local spellSlot = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
	local level = { 0, 0, 0, 0 }
		for i = 1, myHero.level, 1 do
			level[SequenciaHabilidades1[i]] = level[SequenciaHabilidades1[i]] + 1
		end
			for i, v in ipairs({ myHero:GetSpellData(_Q).level, myHero:GetSpellData(_W).level, myHero:GetSpellData(_E).level, myHero:GetSpellData(_R).level }) do
				if v < level[i] then LevelSpell(spellSlot[i]) end
			end
	end
end 
--[[END]]--

function AtualizaItems()
--[[ITEMS]]--
	DFG.slot = GetInventorySlotItem(DFG.id)	
	ZHONIA.slot = GetInventorySlotItem(ZHONIA.id)
	Seraph.slot = GetInventorySlotItem(Seraph.id)
	Hppotion.slot = GetInventorySlotItem(Hppotion.id)
	Manapotion.slot = GetInventorySlotItem(Manapotion.id)
	MinionsInimigos:update()	
end

--[[SPELLS END]]--
function OnTick()
	if Menu.LigarScript and not myHero.dead then		
		if Menu.General.UseOrb then Menu.General.MoveToMouse = false end
		if Menu.General.MoveToMouse then Menu.General.UseOrb = false end
		if Menu.Paint.EnemyDamage then MeuDano() end
		AtualizaItems()		
		if Menu.Combo.ComboSystem then
			CastCombo()		
		end
		if Menu.Harass.HarassSystem then
			if Menu.Harass.AutoHarass and ((myHero.mana / myHero.maxMana * 100)) >= Menu.Harass.ParaComManaBaixa and not UsandoR and not UsandoRecall and not Menu.Harass.HarassKey then
				CastHarass()		
			else
				if Menu.Harass.HarassKey and ((myHero.mana / myHero.maxMana * 100)) >= Menu.Harass.ParaComManaBaixa and not Menu.Harass.AutoHarass and not UsandoR and not UsandoRecall then
					CastHarass()
				end	
			end
		end
		if Menu.Items.ItemsSystem then
			if Menu.Items.UseBarreira then CastBarreira() end
			if Menu.Items.AutoHP then CastHPPotion() end
			if Menu.Items.AutoMANA then CastManaPotion() end
			if Menu.Items.UseZhonia then CastZhonia() end			
			if Menu.Items.UseSeraph then CastSeraph() end
		end
		if Menu.Farmerr.FarmerrSystem then
			if Menu.Farmerr.LastHit then
				LastHitLikeBoss()
			end
		end
		if Menu.General.LevelSkill then
			AutoSkillLevel()
		end
	end
end

--[[ULTIMATE/BUFFS CONTROL]]--
function OnGainBuff(unit, buff)
	if unit.isMe then
	--[[
		if buff.name:lower():find("alzaharnethergraspsound") then
			UsandoR = true
		end
		if buff.name:lower():find("regenerationpotion") then 
			UsandoHP = true
		end	
		if buff.name:lower():find("flaskofcrystalwater") then
			UsandoMana = true
		end		
		if buff.name:lower():find("alzaharsummonvoidling") then
			TemVoid = true
		end	
		]]--
		if buff.name:lower():find("recall") then
			UsandoRecall = true
		end
	end	
end

function OnLoseBuff(unit, buff)
	if unit.isMe then
	--[[
		if buff.name:lower():find("alzaharnethergraspsound") then
			UsandoR = false
		end
		if buff.name:lower():find("regenerationpotion") then 
			UsandoHP = false
		end
		if buff.name:lower():find("flaskofcrystalwater") then
			UsandoMana = false
		end
		--if buff.type == 5 or 7 or 19 or 21 or 24 then
		-- RecebeuCC = false
		--end
		if buff.name:lower():find("alzaharsummonvoidling") then
			TemVoid = false
		end
		]]--
		if buff.name:lower():find("recall") then
			UsandoRecall = false
		end
	end	
end
--[[END]]--

--[[MY TARGET SELECTOR]]--
function MelhorAlvo(Range) --ADICIONAR DELAY	
	local DanoParaMatar = 100
	local Alvo = nil
	if Menu.General.SelecionarAlvo == 1 then --less_cast
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy, Range) then
			local DanoNoInimigo = myHero:CalcMagicDamage(enemy, 200)
			local ParaMatar = enemy.health / DanoNoInimigo
				if ParaMatar < DanoParaMatar then
					Alvo = enemy
				end
		end
	end
	end	
	
	if Menu.General.SelecionarAlvo == 2 then --low_HP
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy, Range) then
			local DanoNoInimigo = myHero:CalcMagicDamage(enemy, 200)
			local ParaMatar = enemy.health / enemy.health - DanoNoInimigo
				if ParaMatar < DanoParaMatar then
					Alvo = enemy
				end
		end
	end
	end	
	return Alvo
end
--[[END]]--

--[[ORBWALK]]--
function OnProcessSpell(object, spell)
	if object == myHero then
		if spell.name:lower():find("attack") then
			lastAttack = GetTickCount() - GetLatency() / 2
			lastWindUpTime = spell.windUpTime * 1000
			lastAttackCD = spell.animationTime * 1000
		end 
		if spell.name:find("AlZaharNetherGrasp") then
			UsandoR = true
		else
			UsandoR = false
		end
	end
	
end

function _OrbWalk()
	local AlvoOrb = MelhorAlvo(myTrueRange)
	if AlvoOrb ~= nil and GetDistance(AlvoOrb) <= myTrueRange then		
		if timeToShoot() then
			myHero:Attack(AlvoOrb)
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
	return ( GetTickCount() + GetLatency() / 2 > lastAttack + lastAttackCD )
end 
 
function moveToCursor()
	if GetDistance(mousePos) > 1 or lastAnimation == "Idle1" then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized() * 250
		myHero:MoveTo(moveToPos.x, moveToPos.z)
	end 
end
--[[ORBWALK END]]--

--[[Credits to barasia, vadash and viseversa for anti-lag circles]]--
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8,math.floor(180/math.deg((math.asin((chordlength/(2*radius)))))))
	quality = 2 * math.pi / quality
	radius = radius*.92
	local points = {}
	for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
		points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	end
	DrawLines2(points, width or 1, color or 4294967295)
end

function DrawCircle2(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
	if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
		DrawCircleNextLvl(x, y, z, radius, 1, color, 75)	
	end
end
--[[END]]--
--[[DRAW]]--
function OnDraw()

	if myHero.dead or not Menu.Paint.DrawSystem then return end
	
	if Menu.Paint.PaintQ then
		DrawCircle2(myHero.x, myHero.y, myHero.z, BrandBlaze.range,  ARGB(255, 255, 000, 000))
	end 
	if Menu.Paint.PaintW then
		DrawCircle2(myHero.x, myHero.y, myHero.z, BrandFissure.range,  ARGB(255, 000, 000, 255))
	end 
	if Menu.Paint.PaintE then
		DrawCircle2(myHero.x, myHero.y, myHero.z, BrandConflagration.range,  ARGB(255, 000, 255, 000))
	end 
	if Menu.Paint.PaintR then
		DrawCircle2(myHero.x, myHero.y, myHero.z, BrandWildfire.range,  ARGB(255, 255, 255, 000))
	end 
	if Menu.Paint.PaintFlash then
		DrawCircle2(myHero.x, myHero.y, myHero.z, IgniteSpell.range, ARGB(255, 000, 000, 255))
	end 
	if Menu.Paint.PaintAA then
		DrawCircle2(myHero.x, myHero.y, myHero.z, 550, ARGB(255,255,255,255))
	end
	
	if Menu.Paint.EnemyDamage then		
		local AlvoP = MelhorAlvo(1400)
		if AlvoP ~= nil then
			DrawText3D(CalcularDanoInimigo(), myHero.x +30, myHero.y, myHero.z, 16, ARGB(255,255,255,000))
			DrawText3D(MeuDano(), myHero.x, myHero.y + 100, myHero.z, 16, ARGB(255,255,000,000))
		end
	end
	
	if Menu.Paint.PaintMinion then
		if MinionsInimigos ~= nil then
		local DamageArcane1 = myHero.ap * 0.05
		local DamageButcher1 = 2
		local MasteryDamage1 = 0
			if Menu.Farmerr.ArcaneON then
				MasteryDamage1 = MasteryDamage1 + DamageArcane1
			end
			if Menu.Farmerr.ButcherON then
				MasteryDamage1 = MasteryDamage1 + DamageButcher1
			end
			for i, Minion in pairs(MinionsInimigos.objects) do
				if Minion ~= nil and not Minion.dead then
					if ValidTarget(Minion, 1200) and Minion.health <= getDmg("AD", Minion, myHero) + MasteryDamage1 then
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
					hitsToTurret = Arredondar(turret.object.health / getDmg("AD", targetTurret, myHero))
						if hitsToTurret ~= 0 then
							local pos= WorldToScreen(D3DXVECTOR3(targetTurret.x, targetTurret.y, targetTurret.z))
							local posX = pos.x - 35
							local posY = pos.y - 50							
								DrawText("AA Hits: "..hitsToTurret + 1,15,posX ,posY  ,ARGB(255,0,255,0))
								if Menu.Paint.PaintTurrentRange then
									DrawCircle2(targetTurret.x, targetTurret.y, targetTurret.z, 930, ARGB(255,0,255,0))
								end
						end
				end
			end
	end
	
	if Menu.Paint.PaintTarget then
		local AlvoPP = MelhorAlvo(1400)
		if AlvoPP  ~= nil then			 	 
			for i=0, 4 do
				 DrawCircle2(AlvoPP.x, AlvoPP.y, AlvoPP.z, 60 + i*1.5, ARGB(255, 255, 000, 255))	
			end
		end 
	end
	
	if Menu.Paint.PaintPassive then
		if TemVoid then			
			DrawCircle2(myHero.x, myHero.y, myHero.z, 65, ARGB(255,255,255,255))
		end
	end

	if Menu.Paint.PaintMana and myHero.mana < myHero.maxMana * (Menu.Harass.ParaComManaBaixa / 100) then		
		DrawCircle2(myHero.x, myHero.y, myHero.z, 35, ARGB(255, 000, 000, 255))	
	end	
	
	if Menu.Paint.PredInimigo then
		local AlvoPred = MelhorAlvo(1200)
		if AlvoPred ~= nil then
			wayPointManager:DrawWayPoints(AlvoPred)
		end
	end
	
	if Menu.Paint.ManaCheck then				
		DrawText3D(ManaParaCombo(), myHero.x + 20, myHero.y + 50, myHero.z, 16, ARGB(255, 000, 255, 255))
	end
	
end
--[[MISC]]--

function TemImunidade(enemy)
	if Menu.Combo.Ultimate.Untargetable then
		for i, Imunidades in ipairs(Invulneraveis) do
		if TargetHaveBuff(Imunidades[i], enemy) then
			return true
		else
			return false
		end
		end
	end
end

function CalcularDanoInimigo()
	local AlvoCalc = MelhorAlvo(1400)
	if AlvoCalc ~= nil then	
		adDmgE = (getDmg("AD", myHero, AlvoCalc) or 0)		
		qDmgE = (getDmg("Q", myHero, AlvoCalc) or 0)
		wDmgE =  (getDmg("W", myHero, AlvoCalc) or 0)
		eDmgE = (getDmg("E", myHero, AlvoCalc) or 0)
		rDmgE = (getDmg("R", myHero, AlvoCalc) or 0)
		local DanoInimigo = qDmgE + wDmgE + eDmgE + rDmgE + adDmgE
		local PorcentagemQueVouFicar = ((((myHero.maxHealth - DanoInimigo)/myHero.maxHealth)*100) or 0)			
		return "Total Enemy Damage:"..Arredondar(DanoInimigo).." / Stay: "..Arredondar(PorcentagemQueVouFicar).."%:My HP:"..Arredondar(myHero.health).."/"..Arredondar(myHero.maxHealth)
	else
		return "No enemy/My HP:"..Arredondar(myHero.health).."/"..Arredondar(myHero.maxHealth)
	end
end		
-- 0.03 from mastery Havoc
function MeuDano()
		if not ((os.clock() + AtualizarDanoInimigo) > 0.5) then return end
		local AlvoDano = MelhorAlvo(1400)
		if AlvoDano ~= nil then
			local DanoQ = { 80 , 120 , 160 , 200 , 240 }
			local DanoW = { 75 , 120 , 165 , 210 , 255 }
			local DanoE = { 70 , 105 , 140 , 175 , 210 }
			local DanoR = {	150 , 250 , 350 }			
			local DanoTotal, QDano, WDano, EDano, RDano, DFGDano = 0, 0, 0, 0, 0
				if myHero:GetSpellData(_Q).level ~= 0 then
					QDano = myHero:CalcMagicDamage(AlvoDano, (DanoQ[myHero:GetSpellData(_Q).level] + myHero.ap * 0.65) + ((DanoQ[myHero:GetSpellData(_Q).level] + myHero.ap * 0.65)* 0.03))
				end
				if myHero:GetSpellData(_W).level ~= 0 then
					WDano = myHero:CalcMagicDamage(AlvoDano, (DanoQ[myHero:GetSpellData(_Q).level] + myHero.ap * 0.6) + ((DanoQ[myHero:GetSpellData(_Q).level] + myHero.ap * 0.6)* 0.03))
				end
				if myHero:GetSpellData(_E).level ~= 0 then
					EDano = myHero:CalcMagicDamage(AlvoDano, (DanoE[myHero:GetSpellData(_E).level] + myHero.ap * 0.55) + (DanoE[myHero:GetSpellData(_E).level] + myHero.ap * 0.55) * 0.03)
				end
				if myHero:GetSpellData(_R).level ~= 0 then
					RDano = myHero:CalcMagicDamage(AlvoDano, (DanoR[myHero:GetSpellData(_R).level] + myHero.ap * 0.5) + (DanoR[myHero:GetSpellData(_R).level] + myHero.ap * 0.5) * 0.03)
				end				
				DanoTotal = QDano + WDano + EDano + RDano				
				DanoTotal = DanoTotal
				PorcentagemQueVouFicar = ((AlvoDano.maxHealth - DanoTotal)/AlvoDano.maxHealth*100)
				AtualizarDanoInimigo = os.clock()
				return "Damage to Enemy: "..Arredondar(DanoTotal, 1).." : Stay("..Arredondar(PorcentagemQueVouFicar).."%)"
		end			
end	

function Arredondar(num, idp)
 return string.format("%." .. (idp or 0) .. "f", num)
end

function ManaParaCombo()	
	local qMana = myHero:GetSpellData(_Q).mana or 0
	local wMana = myHero:GetSpellData(_W).mana or 0
	local eMana = myHero:GetSpellData(_E).mana or 0
	local rMana = myHero:GetSpellData(_R).mana or 0
	local ManaTotal = 0
		if Menu.Combo.UseQ then ManaTotal = ManaTotal + qMana end
		if Menu.Combo.UseW then ManaTotal = ManaTotal + wMana end
		if Menu.Combo.UseE then ManaTotal = ManaTotal + eMana end
		if Menu.Combo.UseR then ManaTotal = ManaTotal + rMana end
			if myHero.mana < ManaTotal then
				return "Not Enought Mana to Combo."
			end
end

function LastHitLikeBoss()	
	local tick = os.clock()
	local nexttick = 0
	local TimeToTheFirstDamageTick  = 2.0
	local ProjectileSpeed = myHero.attackSpeed --AA speed
	local delay = -0.1125 + TimeToTheFirstDamageTick -- AA delay	
	local DamageArcane1 = myHero.ap * 0.05
	local DamageButcher1 = 2
	local MasteryDamage1 = 0
		if Menu.Farmerr.ArcaneON then
			MasteryDamage1 = MasteryDamage1 + DamageArcane1
		end
		if Menu.Farmerr.ButcherON then
			MasteryDamage1 = MasteryDamage1 + DamageButcher1
		end		
		if MinionsInimigos ~= nil then
			for i, Minion in ipairs(MinionsInimigos.objects) do
				if Minion ~= nil and not Minion.dead then
					local Healthh = VP:GetPredictedHealth(Minion, delay + GetDistance(Minion, myHero) / ProjectileSpeed)
					if Healthh ~= nil and ValidTarget(Minion, 550) and Healthh <= getDmg("AD", Minion, myHero) + MasteryDamage1 and os.clock() > nexttick then						
						myHero:Attack(Minion)
						nexttick = os.clock() + GetLatency() / 2 + Menu.Farmerr.LastHitDelay
					end
				end
			end
		end
		if os.clock() > nexttick then
			myHero:MoveTo(mousePos.x, mousePos.z)
		end
end
