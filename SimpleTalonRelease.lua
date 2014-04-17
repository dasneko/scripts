local version = "2.028"

if myHero.charName ~= "Talon" or not VIP_USER then return end

local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Jusbol/scripts/master/SimpleTalonRelease.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = LIB_PATH.."SimpleTalonRelease.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>Talon, Tail of the Dragon:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, UPDATE_PATH)
	if ServerData then
		local ServerVersion = string.match(ServerData, "local version = \"%d+.%d+\"")
		ServerVersion = string.match(ServerVersion and ServerVersion or "", "%d+.%d+")
		if ServerVersion then
			ServerVersion = tonumber(ServerVersion)
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available"..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end

require "VPrediction"

--[[AUTO UPDATE END]]--

local TalonNoxianDiplomacy = 	{spellSlot = _Q, range = 250, width = 0, speed = math.huge, delay = 0.0435, ready = nil}
local TalonRake            = 	{spellSlot = _W, range = 700, width = 0, speed = 902, delay = 0.4, ready = nil} --0.8 in/out
local TalonCutthroat       =	{spellSlot = _E, range = 700, width = 0, speed = math.huge, delay = 0.5, ready = nil}
local TalonShadowAssault   =	{spellSlot = _R, range = 650, width = 650, speed = 902, delay = 0.5, ready = nil}
--[[SPELLS]]--
local IgniteSpell   = 	{spellSlot = "SummonerDot", slot = nil, range = 600, ready = false}
local BarreiraSpell = 	{spellSlot = "SummonerBarrier", slot = nil, range = 0, ready = false}
--local FlashSpell = 		{spellSlot = "SummonerFlash", slot = nil, range = 400, ready = false}
--[[ITEMS]]--
local Items = {
			["Brtk"]   = 	{ready = false, range = 450, SlotId = 3153, slot = nil},
			["Bc"]     = 	{ready = false, range = 450, SlotId = 3144, slot = nil},
			["Rh"]     = 	{ready = false, range = 400, SlotId = 3074, slot = nil},
			["Tiamat"] = 	{ready = false, range = 400, SlotId = 3077, slot = nil},
			["Hg"]     = 	{ready = false, range = 700, SlotId = 3146, slot = nil},
			["Yg"]     = 	{ready = false, range = 150, SlotId = 3142, slot = nil},
			["RO"]     = 	{ready = false, range = 500, SlotId = 3143, slot = nil}, 
			["SD"]	   =	{ready = false, range = 150, SlotId = 3131, slot = nil}				
			}
local HP_MANA = { 
				["Hppotion"] = {SlotId = 2003, ready = false, slot = nil},
				["Manapotion"] = {SlotId = 2004 , ready = false, slot = nil}				  
				}
local FoundItems = {}
--[[ORBWALK]]--
local myPlayer 								   = GetMyHero()
local lastAttack, lastWindUpTime, lastAttackCD = 0, 0, 0
local myTrueRange 							   = myPlayer.range + GetDistance(myPlayer.minBBox)
--[[others]]
local SequenciaHabilidades1 = {2,3,2,1,2, 4, 2,1,2,1, 4, 1,1,3,3, 4, 3,3} 
local enemyRangeHitBox 		= 0
local Target 				= nil
local UsandoHP				= false
local UsandoMana			= false
local UsandoRecall			= false
local DamageTable 			= {"P", "AD", "Q", "W", "E", "R", "IGNITE", "BWC", "TIAMAT", "HYDRA", "RUINEDKING"}
local DamageText  			= nil
local BuffNames 			= { "regenerationpotion", "flaskofcrystalwater", "recall" }
local RespawPoint 			= Vector(cameraPos.x, cameraPos.y, cameraPos.z):normalized()
--local DrawLine1			= nil
--local DrawLine2 			= nil
function OnLoad()	
	Menu1()	
	UpdateVariaveis()
	PrintChat("-[ <font color='#000FFF'> -- Talon by Jus loaded !Good Luck! -- </font> ]-")	
end

function Menu1()
Menu = scriptConfig(myPlayer.charName.." by Jus", "TalonMenu")
Menu:addParam("LigarScript", "Global ON/OFF", SCRIPT_PARAM_ONOFF, true)
Menu:addParam("Ver", "Talon Version", SCRIPT_PARAM_INFO, version)
--[[Combo]]
Menu:addSubMenu("Combo System", "Combo")
		Menu.Combo:addParam("ComboSystem", "Use Combo System", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Combo:addParam("UseQ", "Use "..myPlayer:GetSpellData(_Q).name.." (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("UseW", "Use "..myPlayer:GetSpellData(_W).name.." (W)", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("UseE", "Use "..myPlayer:GetSpellData(_E).name.." (E)", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("UseR", "Use "..myPlayer:GetSpellData(_R).name.." (R)", SCRIPT_PARAM_ONOFF, true)		
		Menu.Combo:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Combo:addParam("ComboKey", "Team Fight Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Menu.Combo:addSubMenu("Combo/Team Fight Settings", "CSettings")	
			Menu.Combo.CSettings:addParam("Mode", "Combo Mode", SCRIPT_PARAM_LIST, 2, {"E-Q-W-R", "W-E-Q-R", "E-W-R-Q"})		
			Menu.Combo.CSettings:addParam("Rdelay", "Ultimate delay to second cast", SCRIPT_PARAM_LIST, 4, {"0", "0.5", "1.0", "1.5", "2.0", "2.5"})
			Menu.Combo.CSettings:addParam("scapeMode", "Scape Mode Prioritization", SCRIPT_PARAM_LIST, 1, {"Minion", "Enemy"}) -- "Auto"})
			Menu.Combo.CSettings:addParam("scapeKey", "Scape with "..myPlayer:GetSpellData(_E).name.." (E)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
			Menu.Combo.CSettings:addParam("UseItems", "Auto Use Items", SCRIPT_PARAM_ONOFF, true)
			Menu.Combo.CSettings:addParam("UseIgnite", "Auto Ignite Target", SCRIPT_PARAM_ONOFF, true)
Menu:addSubMenu("Harass System", "Harass")
		Menu.Harass:addParam("HarassSystem", "Use Harass System", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Harass:addParam("HarassMode", "Harass Mode", SCRIPT_PARAM_LIST, 1, { "W", "E-Q-W", "E-Q" })
		Menu.Harass:addParam("UseAutoW", "Auto Cast W", SCRIPT_PARAM_ONOFF, false)
		Menu.Harass:addParam("StopCastMana", "Don't Harass if mana < %", SCRIPT_PARAM_SLICE, 40, 0, 100, -1)
		Menu.Harass:addParam("UseW", "Use "..myPlayer:GetSpellData(_W).name.." (W)", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("HarassKey", "Manual Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
--[[Farm]]
Menu:addSubMenu("Farm Helper System", "Farmerr")
		Menu.Farmerr:addParam("FarmerrSystem", "Use Farm System", SCRIPT_PARAM_ONOFF, true)
		Menu.Farmerr:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Farmerr:addParam("UseAutoW", "Auto Cast W", SCRIPT_PARAM_ONOFF, false)
		Menu.Farmerr:addParam("UseW", "Cast W if minion count >", SCRIPT_PARAM_LIST, 2, {"1", "2", "3", "4", "5", "OFF"})
		Menu.Farmerr:addParam("StopCastMana", "Stop Cast W if mana below %", SCRIPT_PARAM_SLICE, 40, 20, 100, -1)
		Menu.Farmerr:addParam("", "", SCRIPT_PARAM_INFO, "")		
		Menu.Farmerr:addParam("FarmKey", "Manual Farm Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
--[[Items]]
Menu:addSubMenu("Items Helper System", "Items")
		Menu.Items:addParam("ItemsSystem", "Use Items Helper System", SCRIPT_PARAM_ONOFF, true)
		Menu.Items:addParam("", "", SCRIPT_PARAM_INFO, "")		
		Menu.Items:addParam("UseBarreira", "Auto Barrier", SCRIPT_PARAM_ONOFF, true)
		Menu.Items:addParam("BarreiraPorcentagem", "Barrier Missing Health %", SCRIPT_PARAM_SLICE, 30, 10, 80, -1)
		Menu.Items:addParam("AntiDoubleIgnite", "Anti Double Ignite", SCRIPT_PARAM_ONOFF, true) 
		Menu.Items:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Items:addParam("AutoHP", "Auto HP Potion", SCRIPT_PARAM_ONOFF, true)
		Menu.Items:addParam("AutoHPPorcentagem", "Use HP Potion if health %", SCRIPT_PARAM_SLICE, 60, 20, 80, -1)
		Menu.Items:addParam("AutoMana", "Auto Mana Potion", SCRIPT_PARAM_ONOFF, true)
		Menu.Items:addParam("AutoMANAPorcentagem", "Use Mana Potion if health %", SCRIPT_PARAM_SLICE, 60, 20, 80, -1)
--[[Draw]]
Menu:addSubMenu("Draw System", "Paint")
		Menu.Paint:addParam("DrawSystem", "Use Draw System", SCRIPT_PARAM_ONOFF, true)
		Menu.Paint:addParam("", "", SCRIPT_PARAM_INFO, "")		
		Menu.Paint:addParam("PaintW", "Draw "..myPlayer:GetSpellData(_W).name.." (W) Range", SCRIPT_PARAM_ONOFF, false)
		Menu.Paint:addParam("PaintE", "Draw "..myPlayer:GetSpellData(_E).name.." (E) Range", SCRIPT_PARAM_ONOFF, true)
		Menu.Paint:addParam("PaintR", "Draw "..myPlayer:GetSpellData(_R).name.." (R) Range", SCRIPT_PARAM_ONOFF, false)
		Menu.Paint:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.Paint:addParam("PaintTarget", "Draw Target", SCRIPT_PARAM_ONOFF, true)
		Menu.Paint:addParam("KillTarget", "Draw Text to Target", SCRIPT_PARAM_ONOFF, true)
		--Menu.Paint:addParam("", "", SCRIPT_PARAM_INFO, "")
		--Menu.Paint:addParam("HotSpot", "Draw Hotspots", SCRIPT_PARAM_ONOFF, false)
--[[Others]]
Menu:addSubMenu("General System", "General")
		Menu.General:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.General:addParam("LevelSkill", "Auto Level Skills R-W-Q-E", SCRIPT_PARAM_ONOFF, true)		
		Menu.General:addParam("UseOrb", "Use Orbwalking", SCRIPT_PARAM_ONOFF, true)		
		Menu.General:addParam("", "", SCRIPT_PARAM_INFO, "")
		Menu.General:addParam("UsePacket", "Use Packet to Cast", SCRIPT_PARAM_ONOFF, true)
		Menu.General:addParam("UseVPred", "Use VPredicion to Cast", SCRIPT_PARAM_ONOFF, true)
		--Menu.General:addParam("AutoUpdate", "Auto Update Script On Start", SCRIPT_PARAM_ONOFF, true)
--[[PermaShow Options]]
	Menu:permaShow("Ver")
	Menu.Combo:permaShow("ComboKey")
	Menu.Harass:permaShow("HarassKey")
	Menu.Farmerr:permaShow("FarmKey")
	Menu.Combo.CSettings:permaShow("scapeKey")
--[[spells]]
	if myPlayer:GetSpellData(SUMMONER_1).name:find(IgniteSpell.spellSlot) then IgniteSpell.slot = SUMMONER_1
	elseif myPlayer:GetSpellData(SUMMONER_2).name:find(IgniteSpell.spellSlot) then IgniteSpell.slot = SUMMONER_2 end	
	if myPlayer:GetSpellData(SUMMONER_1).name:find(BarreiraSpell.spellSlot) then BarreiraSpell.slot = SUMMONER_1
	elseif myPlayer:GetSpellData(SUMMONER_2).name:find(BarreiraSpell.spellSlot) then BarreiraSpell.slot = SUMMONER_2 end
--[[others_func]]
--[[
	enemyHeroes = GetEnemyHeroes()	
	if heroManager.iCount < 10 then -- borrowed from Sidas Auto Carry, modified to 3v3
	   	PrintChat(" >> Too few champions to arrange priority")
	elseif heroManager.iCount == 6 and TTMAP then
		ArrangeTTPriorities()
	else
		ArrangePriorities()
	end
	]]
	--[[MMA/SAC Disable orbwalk]]--
	
--[[Ts/minion/jungle]]
	Alvo = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1200, DAMAGE_PHYSICAL, true)
	Alvo.name = "Talon"
	Menu:addTS(Alvo)	
	MinionsInimigos = minionManager(MINION_ENEMY, TalonRake.range, myPlayer, MINION_SORT_HEALTH_ASC)	
	VP = VPrediction()
end

function ValidSpell(spellslot_) --_Q, _W...	
	local Ready 	=	myPlayer:CanUseSpell(spellslot_) == READY	
	return spellslot_ ~= nil and Ready 
end

function UpdateVariaveis()
	--[[SKILLS]]--
	--if (myPlayer:CanUseSpell(TalonNoxianDiplomacy.spellSlot) == READY) then TalonNoxianDiplomacy.ready = true else TalonNoxianDiplomacy.ready = false end
	--if (myPlayer:CanUseSpell(TalonRake.spellSlot) == READY) then TalonRake.ready = true else TalonRake.ready = false end
	--if (myPlayer:CanUseSpell(TalonCutthroat.spellSlot) == READY) then TalonCutthroat.ready = true else TalonCutthroat.ready = false end
	--if (myPlayer:CanUseSpell(TalonShadowAssault.spellSlot) == READY) then TalonShadowAssault.ready = true else TalonShadowAssault.ready = false end
--[[TARGET SELECTOR]]--
	--Alvo:update()	
	Target = GetCustomTarget()
	if ValidTarget(Target) then enemyRangeHitBox = VP:GetHitBox(Target) else enemyRangeHitBox = 0 end
--[[MINION MANAGER]]--
	MinionsInimigos:update()
end

--[[cast SKILLs]]

function CastQ(myTarget)
	local UseQ_ 	=	Menu.Combo.UseQ
	local sReady	=	ValidSpell(_Q)
	if not UseQ_ then return end	
	if ValidTarget(myTarget, TalonNoxianDiplomacy.range) and sReady then --and GetDistance(myTarget) <= TalonNoxianDiplomacy.range then		
		if Menu.General.UsePacket then
			Packet('S_CAST', { spellId = TalonNoxianDiplomacy.spellSlot, targetNetworkId = myPlayer.networkID }):send()							
		else
			CastSpell(TalonNoxianDiplomacy.spellSlot)					
		end
	end
end

function CastW(myTarget)
	local UseW_  	= 	Menu.Combo.UseW
	local sReady	=	ValidSpell(_W)
	if not UseW_ then return end
	if ValidTarget(myTarget, TalonRake.range) and sReady then
		if Menu.General.UseVPred then
			local mainCastPosition, mainHitChance = VP:GetConeAOECastPosition(myTarget,
																			  ((TalonRake.delay + 350)/TalonRake.speed), 
																			  52, 
																			  TalonRake.range, 
																			  TalonRake.speed, 
																			  myPlayer)
			if mainHitChance >= 2 then
				Packet('S_CAST', { spellId = TalonRake.spellSlot, toX = mainCastPosition.x, toY = mainCastPosition.z }):send()
				--CastSpell(TalonRake.spellSlot, mainCastPosition.x, mainCastPosition.z)
			end
		else
			CastSpell(TalonRake.spellSlot, myTarget.x, myTarget.z)
		end
	end
end

function CastE(myTarget)
	local UseE_  	= 	Menu.Combo.UseE
	local sReady	=	ValidSpell(_E)
	if not UseE_ then return end
	if ValidTarget(myTarget, TalonCutthroat.range) and sReady then		
		if Menu.General.UsePacket then
			Packet('S_CAST', { spellId = TalonCutthroat.spellSlot, targetNetworkId = myTarget.networkID }):send()
			lastAttackCD = 0					
		else
			CastSpell(TalonCutthroat.spellSlot, myTarget)
			lastAttackCD = 0						
		end
	end
end

function CastR(myTarget)
	local UseR_  	= 	Menu.Combo.UseR
	local rDelay 	= 	Menu.Combo.CSettings.Rdelay
	local sReady	=	ValidSpell(_R)
	if not UseR_ then return end
	if ValidTarget(myTarget, TalonShadowAssault.range) and sReady then
		if Menu.General.UseVPred then
			local AOECastPosition, MainTargetHitChance, nTargets = VP:GetCircularAOECastPosition(myTarget,
																								 TalonShadowAssault.delay,
																								 TalonShadowAssault.width, 
																								 TalonShadowAssault.range,
																								 TalonShadowAssault.speed, 
																								 myPlayer) 
			if MainTargetHitChance >= 2 then				
				CastSpell(TalonShadowAssault.spellSlot, AOECastPosition.x, AOECastPosition.z)
				DelayAction(function ()
								CastSpell(TalonShadowAssault.spellSlot, AOECastPosition.x, AOECastPosition.z)
							end,
							rDelay + GetLatency() / 2)
			end
		else
			CastSpell(TalonShadowAssault.spellSlot, myTarget.x, myTarget.z)
			DelayAction(function ()
						CastSpell(TalonShadowAssault.spellSlot, myTarget.x, myTarget.z)
						end,
						rDelay + GetLatency() / 2)
		end
	end
end

function NewCastR(myTarget)
	local UseR_  	= 	Menu.Combo.UseR
	local rDelay 	= 	Menu.Combo.CSettings.Rdelay
	local sReady	=	ValidSpell(_R)	
	if not UseR_ then return end
	if ValidTarget(myTarget, TalonShadowAssault.range) and sReady then
		local MyPos			= 	Vector(myPlayer):normalized()
		local EnemyPosition	=	Vector(myTarget - MyPos):normalized()	
		if EnemyPosition < MyPos then
			CastSpell(TalonShadowAssault.spellSlot, myTarget.x, myTarget.z)
			DelayAction(function ()
							CastSpell(TalonShadowAssault.spellSlot, myTarget.x, myTarget.z)
						end,
						rDelay + GetLatency() / 2)
		end
	end
end


--[[end]]

--[[cast Spells/items]]
function CheckItems(tabela)
	for ItemIndex, Value in pairs(tabela) do
		Value.slot = GetInventorySlotItem(Value.SlotId)
		--local sReady	=	ValidSpell(Value.slot)
			--if sReady then 	
			if Value.slot ~= nil and (myPlayer:CanUseSpell(Value.slot) == READY) then 				
			--table.insert(FoundItems, ItemIndex)		
			FoundItems[#FoundItems+1] = ItemIndex	
		end
	end
end

function CastCommonItem()
	CheckItems(Items)
	if #FoundItems ~= 0 then
		for i, Items_ in pairs(FoundItems) do
			if Target ~= nil then				
				if GetDistance(Target) <= Items[Items_].range then 
					if 	Items_ == "Brtk" or Items_ == "Bc" then
						CastSpell(Items[Items_].slot, Target)
					else					
						CastSpell(Items[Items_].slot)					
					end
				end
			end
			FoundItems[i] = nil --clear table to optimaze
		end	
	end
end

function CastSurviveItem()
	CheckItems(HP_MANA)		
	local AutoHPPorcentagem_ 	= Menu.Items.AutoHPPorcentagem
	local AutoMANAPorcentagem_ 	= Menu.Items.AutoMANAPorcentagem
	local HP_Porcentagem 		= (myPlayer.health / myPlayer.maxHealth *100)
	local MANA_Porcentagem		= (myPlayer.mana / myPlayer.maxMana *100)
	local UseBarreira_			= Menu.Items.UseBarreira
	local UseBarreiraPorcen_	= Menu.Items.BarreiraPorcentagem
	local UseBarreiraPorcen_1 	= (myPlayer.health / myPlayer.maxHealth *100)
	if #FoundItems ~= 0 then	
		for i, HP_MANA_ in pairs(FoundItems) do
			if HP_MANA_ == "Hppotion" and HP_Porcentagem <= AutoHPPorcentagem_  and not InFountain() and not UsandoHP then
				CastSpell(HP_MANA[HP_MANA_].slot)
			end
			if HP_MANA_ == "Manapotion" and MANA_Porcentagem <= AutoMANAPorcentagem_  and not InFountain() and not UsandoMana then
				CastSpell(HP_MANA[HP_MANA_].slot)
			end			
		FoundItems[i] = nil
		end
		if BarreiraSpell.slot ~= nil and UseBarreira_ and UseBarreiraPorcen_1 <= UseBarreiraPorcen_ and not InFountain() then
			CastSpell(BarreiraSpell.slot)
		end 
	end
end

--[[ULTIMATE/BUFFS CONTROL]]--
function OnGainBuff(unit, buff)
	if unit.isMe then
		for i=1, #BuffNames do
			if buff.name:lower():find(BuffNames[i]) then
				if BuffNames[i] == "regenerationpotion" then UsandoHP = true end
				if BuffNames[i] == "flaskofcrystalwater" then UsandoMana = true end
				if BuffNames[i] == "recall" then UsandoRecall = true end
			end
		end
	end
end

function OnLoseBuff(unit, buff)
	if unit.isMe then
		for i=1, #BuffNames do
			if buff.name:lower():find(BuffNames[i]) then
				if BuffNames[i] == "regenerationpotion" then UsandoHP = false end
				if BuffNames[i] == "flaskofcrystalwater" then UsandoMana = false end
				if BuffNames[i] == "recall" then UsandoRecall = false end
			end
		end
	end
end

--[[old OnGainBuff function
function OnGainBuff(unit, buff)
	if unit.isMe then		
		if buff.name:lower():find("regenerationpotion") then 
			UsandoHP = true
		end	
		if buff.name:lower():find("flaskofcrystalwater") then
			UsandoMana = true
		end			
		if buff.name:lower():find("recall") then
			UsandoRecall = true
		end
	end		
end
]]

--[[old InLoseBuff function
function OnLoseBuff(unit, buff)
	if unit.isMe then		
		if buff.name:lower():find("regenerationpotion") then 
			UsandoHP = false
		end
		if buff.name:lower():find("flaskofcrystalwater") then
			UsandoMana = false
		end			
		if buff.name:lower():find("recall") then
			UsandoRecall = false
		end	
	end	
end
]]


--[[end]]

function OnTick()
	--[[Script]]
	local OnOff 				=	Menu.LigarScript
	--[[Combo]]
	local Usar 		 			= 	Menu.Combo.ComboKey
	local UsarItems_ 			= 	Menu.Combo.CSettings.UseItems
	local UsarScape_			= 	Menu.Combo.CSettings.scapeKey
	local ComboMode				= 	Menu.Combo.CSettings.Mode
	--[[Harass]]
	local UsarHarass 			= 	Menu.Harass.HarassSystem
	local UsarHarassKey			= 	Menu.Harass.HarassKey	
	local UsarAutoHarass		= 	Menu.Harass.UseAutoW
	local StopCastManaP			= 	Menu.Harass.StopCastMana
	local MyMana_				= 	(myPlayer.mana / myPlayer.maxMana *100)
	--[[Farm]]	
	local FarmerrSystem_		= 	Menu.Farmerr.FarmerrSystem
	local FarmUseW_				= 	Menu.Farmerr.UseW
	local UsarAutoFarm			= 	Menu.Farmerr.UseAutoW
	local UsarFarmKey			= 	Menu.Farmerr.FarmKey
	--[[Others]]
	local AutoHP_ 	 			= 	Menu.Items.AutoHP
	local AutoMana_	 			= 	Menu.Items.AutoMana
	local AutoLevelSkills_      = 	Menu.General.LevelSkill
	local UseOrb_				= 	Menu.General.UseOrb
	local UseIgnite_			= 	Menu.Combo.CSettings.UseIgnite
	if not OnOff or myPlayer.dead then return end
	UpdateVariaveis()	
	if Usar then
		if _G.MMA_Loaded then			
			_G.MMA_AbleToMove = false			
		end
		if _G.AutoCarry then			
			_G.AutoCarry.CanMove = false			
		end
		if UseOrb_ then _OrbWalk(Target) end		
		if UseIgnite_ then CastIgnite(Target) end
		if ComboMode == 1 then --"E-Q-W-R"
			CastE(Target)
			if not TalonCutthroat.ready then CastQ(Target) end
			if not TalonNoxianDiplomacy.ready then CastW(Target) end
			if not TalonRake.ready then	CastR(Target) end
		end
		if ComboMode == 2 then --"W-E-Q-R"
			CastW(Target)
			if not TalonRake.ready then	CastE(Target) end
			if not TalonCutthroat.ready then CastQ(Target) end
			if not TalonNoxianDiplomacy.ready then CastR(Target) end
		end
		if ComboMode == 3 then --"E-W-R-Q"
			CastE(Target)
			if not TalonCutthroat.ready then CastW(Target) end
			if not TalonRake.ready then CastR(Target) end
			if not TalonShadowAssault.ready then CastQ(Target) end
		end
		if UsarItems_ then CastCommonItem()	end
	end
	
	if UsarScape_ then
		if UseOrb_ then _OrbWalk() end
		ScapeRules()
	end
	
	if UsarHarass then
		if UsarAutoHarass and MyMana_ >= StopCastManaP then
			CastW(Target)						
		end
		if UsarHarassKey and MyMana_ >= StopCastManaP then
			SmartHarass(Target)
			if UseOrb_ then _OrbWalk(Target) end
		end
		--end
	end		
	if FarmerrSystem_ then
		if UsarAutoFarm and FarmUseW_ and not UsandoRecall then
			FarmMinionsW()
		else 
			if UsarFarmKey then
				FarmMinionsW()
				if UseOrb_ then _OrbWalk() end
			end
		end
	end
	if AutoLevelSkills_ then AutoSkillLevel() end
	if AutoHP_ or AutoMana_ then CastSurviveItem() end
end

function OnDraw()
	local wDraw 	  = Menu.Paint.PaintW
	local eDraw 	  = Menu.Paint.PaintE
	local rDraw 	  = Menu.Paint.PaintR	
	local tDraw 	  = Menu.Paint.PaintTarget
	local tdDraw	  = Menu.Paint.KillTarget
	local DrawSystem_ = Menu.Paint.DrawSystem
	if not Menu.LigarScript or myPlayer.dead or not DrawSystem_ then return end	
	if wDraw then
		DrawCircle2(myPlayer.x, myPlayer.y, myPlayer.z, TalonRake.range, ARGB(255, 255, 000, 000))
	end
	if eDraw then
		DrawCircle2(myPlayer.x, myPlayer.y, myPlayer.z,  TalonCutthroat.range, ARGB(255,0,255,0))
	end
	if rDraw then
		DrawCircle2(myPlayer.x, myPlayer.y, myPlayer.z, TalonShadowAssault.range, ARGB(255, 255, 255, 000))
	end
	if tDraw and ValidTarget(Target) then
		for i=0, 3, 1 do
			DrawCircle2(Target.x, Target.y, Target.z, 80 + i , ARGB(255, 255, 000, 255))	
		end
	end
	if tdDraw then
		local DamageText_ = KillTextDamage()
		if ValidTarget(Target) and GetDistance(Target) <= 1200 then 
			DrawText3D(tostring(DamageText_),Target.x ,Target.y + 50, Target.z, 22, ARGB(255,255,0,0), true)
		end
	end

	--if DrawLine1 ~= nil then
	--	DrawCircle2(DrawLine1.x, DrawLine1.y, DrawLine1.z, 400, ARGB(255, 255, 255, 000))
	--end
	--if DrawLine2 ~= nil then
	--	DrawLines3D(DrawLine2.x, DrawLine2.y, DrawLine2.z, 10, ARGB(255, 255, 000, 000))
	--end
	
end

function OnProcessSpell(object, spell)
	if object == myPlayer then
		if spell.name:lower():find("attack") then
			lastAttack = GetTickCount() - GetLatency() / 2
			lastWindUpTime = spell.windUpTime * 1000
			lastAttackCD = spell.animationTime * 1000
		end 
	end
end

--[[others functions]]

local HotSpots = {
	{x = 4747.55, y = -46.02, z = 8337.48},
	{x = 1902.06, y = 53.81, z = 9550.72},
	{x = 2851.71, y = 55.04, z = 7629.16},
	{x = 3540.07, y = 55.60, z = 6426.89},
	{x = 6005.74, y = 51.67, z = 4913.65},
	{x = 6972.89, y = 51.67, z = 4993.82},
	{x = 8243.45, y = 55.41, z = 4232.10},
	{x = 9589.52, y = 50.90, z = 6372.92},
	{x = 8828.17, y = 61.94, z = 1932.64}
}

function SmartHarass(myTarget) --"W", "W-E-Q", "E-Q"
	--[[Harass Menu]]
	local HarassMode_			= Menu.Harass.HarassMode

	if HarassMode_ == 1 then
		CastW(myTarget)
	end

	if HarassMode_ == 2 then
		CastW(myTarget)
		if not TalonRake.ready then	CastE(myTarget) end
		if not TalonCutthroat.ready then CastQ(myTarget) end
	end

	if HarassMode_ == 3 then		
		CastE(myTarget) 
		if not TalonCutthroat.ready then CastQ(myTarget) end
	end
end


function ScapeRules()
	if InFountain() then return end
	local Enemys 		= GetEnemyHeroes() --targetmaneger
	local MyPos	 		= Vector(myPlayer.x, myPlayer.y, myPlayer.z):normalized() --vector of myPlayer	
	local EnemyPosT_	= {} --table with vector of all nearby enemies
	local MinionPosT_	= {} --table with vector of all nearby minions
	local scapeMode_	= Menu.Combo.CSettings.scapeMode --{"Minion", "Enemy", "Auto"}]	
	local ScapeTarget 	= nil --final target to cast E

	if IsWallOfGrass(D3DXVECTOR3(MyPos.x, MyPos.y, MyPos.z)) then
		for i, Minions_ in pairs(MinionsInimigos.objects) do
			local MinionPos_ = Vector(Minion_.x, Minion_.y, Minion_.z):normalized()
			if MinionPos_ > MyPos then
				CastSpell(TalonCutthroat.spellSlot, Minions_)
			end
		end
	end

	--[[Cast E if "Enemy" Option]]
	if scapeMode_ == 2 then --Mode 2 = enemy
	--1.Buffer enemy vector pos in a table
		for i, Enemy_ in pairs(Enemys) do
			if ValidTarget(Enemy_, TalonCutthroat.range) then			
				local EnemyPos = Vector(Enemy_.x, Enemy_.y, Enemy_.z):normalized()			
				EnemyPosT_[#EnemyPosT_+1] = EnemyPos					
			end
		end
	--1.1. Check for distance and cast E
		for i, Enemy_ in pairs(EnemyPosT_) do
			for i, myTarget_ in pairs(Enemys) do				
			local EnemyDist = GetDistance(Enemy_, RespawPoint) --distance between EnemyPos and Respaw
			local MyDist	= GetDistance(MyPos, RespawPoint)	--distance between Me and Respaw
			local RealTarget= GetDistance(myTarget_, RespawPoint) --distance between Actual target and Respaw	
				if EnemyDist < MyDist or RealTarget < MyDist and TalonCutthroat.ready then --there is no reason to use "E" if I'm closer to the base than the enemy
					CastSpell(TalonCutthroat.spellSlot, myTarget_)
				end
			end
		EnemyPosT_[i] = nil
		end		
	end	

	--[[Cast E if "Minion" Option]]
	if scapeMode_ == 1 then
	--2. Buff minions vector pos in a table]]
		for i, Minion_ in pairs(MinionsInimigos.objects) do
			if ValidTarget(Minion_, TalonCutthroat.range) then
				local MinionPos = Vector(Minion_.x, Minion_.y, Minion_.z):normalized()			
				MinionPosT_[#MinionPosT_+1] = MinionPos			
			end
		end
	--2.1. Check for distance and cast E
		for i, Minion_ in pairs(MinionPosT_) do
			for i, myMinionTarget_ in pairs(MinionsInimigos.objects) do				
				local MinionDist 	= GetDistance(Minion_, RespawPoint)  --distance between Minion and Respaw
				local MyDist		= GetDistance(MyPos, RespawPoint)
				local RealMinion	= GetDistance(myMinionTarget_, RespawPoint)
				if MinionDist < MyDist or RealMinion < MyDist and CountEnemyHeroInRange(400, Minion_) < 2 and TalonCutthroat.ready then --there is no reason to use "E" if I'm closer to the base than the minion
					CastSpell(TalonCutthroat.spellSlot, myMinionTarget_)
				end
			end
			MinionPosT_[i] = nil
		end				
	end
end
--[[
	
	[[Cast E if Auto Option, see what distance is small between Enemy and Minion
	if scapeMode_ == 3 then
		--PrintChat("Escape Enemy Mode")
		local BestPos = nil
		for i, Enemy_ in pairs(EnemyPosT_) do
			local EnemyDist = GetDistance(Enemy_, RespawPoint)
			local MyDist	= GetDistance(MyPos, RespawPoint)
			if EnemyDist < MyDist then				
				ScapeTarget = Enemy_
			end
		end
		for i, Minion_ in pairs(MinionPosT_) do
			local MinionDist 	= GetDistance(Minion_, RespawPoint)
			local MyDist		= GetDistance(MyPos, RespawPoint)
			if MinionDist < MyDist then				
				ScapeTarget = Minion_
			end
		end
		if ValidTarget(ScapeTarget, TalonCutthroat.range) then
			CastSpell(TalonCutthroat.spellSlot, ScapeTarget)
		end
	end
end
]]


function CastIgnite(myTarget)
	--local IgniteReady 		= (myHero:CanUseSpell(IgniteSpell.slot) == READY)	
	local AntiDoubleIgnite_ = Menu.Items.AntiDoubleIgnite
	if IgniteSpell.slot ~= nil and ValidTarget(myTarget, IgniteSpell.range) then	
		if AntiDoubleIgnite_ and TargetHaveBuff("SummonerDot", myTarget) then return end
		if AntiDoubleIgnite_ and not TargetHaveBuff("SummonerDot", myTarget) then
			if Menu.General.UsePacket then
				Packet('S_CAST', { spellId = IgniteSpell.slot, targetNetworkId = myTarget.networkID }):send()
			else
				CastSpell(IgniteSpell.iSlot, myTarget)
			end
		else
			if Menu.General.UsePacket then
				Packet('S_CAST', { spellId = IgniteSpell.slot, targetNetworkId = myTarget.networkID }):send()
			else
				CastSpell(IgniteSpell.slot, myTarget)
			end
		end
	end
end 

--[[OLD
function KillTextDamage()
	if ValidTarget(Target) then
		local Damage_     = 0
		local TotalDamage = 0		
		for i, DmgTable in pairs(DamageTable) do
			Damage_ = (getDmg(DmgTable, Target, myPlayer) or 0)
			TotalDamage = TotalDamage + Damage_
		end
		--PrintChat(tostring(TotalDamage))
		if Target.health > TotalDamage then
			DamageText = "Need Harass"
		end
		if Target.health < TotalDamage then		
			DamageText = "Fatality!"
		end		
	end
	return DamageText
end
]]
function KillTextDamage()
	if ValidTarget(Target) then
		local Damage_     = 0
		local TotalDamage = 0		
		for i = 1, #DamageTable do
			Damage_ = (getDmg(DamageTable[i], Target, myPlayer) or 0)
			TotalDamage = TotalDamage + Damage_
		end
		--PrintChat(tostring(TotalDamage))
		if Target.health > TotalDamage then
			DamageText = "Need Harass"
		end
		if Target.health < TotalDamage then		
			DamageText = "Fatality!"
		end		
	end
	return DamageText
end

function AutoSkillLevel()	
	if myPlayer:GetSpellData(_Q).level + myPlayer:GetSpellData(_W).level + myPlayer:GetSpellData(_E).level + myPlayer:GetSpellData(_R).level < myPlayer.level then
	local spellSlot = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
	local level = { 0, 0, 0, 0 }
		for i = 1, myPlayer.level, 1 do
			level[SequenciaHabilidades1[i]] = level[SequenciaHabilidades1[i]] + 1
		end
			for i, v in ipairs({ myPlayer:GetSpellData(_Q).level, myPlayer:GetSpellData(_W).level, myPlayer:GetSpellData(_E).level, myPlayer:GetSpellData(_R).level }) do
				if v < level[i] then LevelSpell(spellSlot[i]) end
			end
	end
end 
--[[
function FarmMinionsW()
	local FarmWithW  = Menu.Farmerr.UseW
	local manaStop 	 = Menu.Farmerr.StopCastMana
	local actualMana = (myPlayer.mana / myPlayer.maxMana *100)
	if FarmWithW == 6 then return end
	MinionsInimigos:update()
	for i, Minion in pairs(MinionsInimigos.objects) do
		local wDamage = getDmg("W", Minion, myPlayer) *2
		if ValidTarget(Minion) and GetDistance(Minion) <= TalonRake.range and TalonNoxianDiplomacy.ready and actualMana > manaStop then		
			if Minion.health <= wDamage and MinionsInimigos.iCount > FarmWithW then --check if number of minion is higher than X
				CastW(Minion)
			end
		end
	end
end
]]

--[[
function CountVectorsBetween(V1, V2, points)
		local result = 0	
		local hitpoints = {} 
		for i, test in ipairs(points) do
			local NVector = Vector(V1):crossP(test)
			local NVector2 = Vector(test):crossP(V2)
			if NVector.y >= 0 and NVector2.y >= 0 then
				result = result + 1
				table.insert(hitpoints, test)
			elseif i == 1 then
				return -1 --doesnt hit the main target
			end
		end
		return result, hitpoints
	end
	]]

--function MinionBestPosition()

--[[
function GetMinionAngle() --skill W angle = 52
	MinionsInimigos:update()
	local MyPos	 		= Vector(myPlayer.x, myPlayer.y, myPlayer.z):normalized()
	local MinionPos     = nil
	local MinionTable	= {}
	local MinionTable1  = {}	
	--local FirstMinion 	= nil
	for i, Minion in ipairs(MinionsInimigos.objects) do
		if Minion.type ~= myPlayer.type	then
			MinionPos = Vector(Vector(Minion.x, Minion.y, Minion.z) - MyPos):rotated(0, (52 * math.pi /180 ), 0)
			table.insert(MinionTable, MinionPos)		
		end
	end


	for i, Test in ipairs(MinionTable) do
		for i, Minion in ipairs(MinionsInimigos.objects) do
			local VMinion = Vector(Minion):normalized()
			local V1 = Vector(Test):crossP(VMinion)
			local V2 = Vector(VMinion):crossP(Minion)
			if V1.y >= 0 and V2.y >= 0 then				
				CastSpell(_W, Test.x, Test.y)
			end
		end
	end
end
]]
	--[[

	for a, MinionPos_ in pairs(MinionTable) do
		for b, Minion in pairs(MinionsInimigos.objects) do
			if Minion.type ~= myPlayer.type then
			local MinionPos_2 = Vector(Vector(Minion.x, Minion.y, Minion.z) + MyPos):normalized()
			if MinionPos_ < MinionPos_2 then
				--rotate or not, cast in oposite minions position
				local MinionPos_rotate =  Vector(Vector(MinionPos_.x, MinionPos_.y, MinionPos_.z) + MyPos):rotated(0, 180 / (180*math.pi), 0)				
				CastSpell(_W, MinionPos_rotate.x, MinionPos_rotate.z)
			end
			end
		end
	end
	
end
]]
		

--trees
function GetCustomTarget()
 	Alvo:update() 	
    if _G.MMA_Target and _G.MMA_Target.type == myPlayer.type then return _G.MMA_Target end
    if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myPlayer.type then return _G.AutoCarry.Attack_Crosshair.target end
	return Alvo.target
end
--end

function _OrbWalk(myTarget)	
	if myTarget ~= nil and GetDistance(myTarget) <= myTrueRange then		
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
	return ( GetTickCount() + GetLatency() / 2 > lastAttack + lastAttackCD )
end 
 
function moveToCursor()
	if GetDistance(mousePos) > 1 or lastAnimation == "Idle1" then
		local moveToPos = myPlayer + (Vector(mousePos) - myPlayer):normalized() * 250
		myPlayer:MoveTo(moveToPos.x, moveToPos.z)
	end 
end

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

--[[SIDA Revamped]]--

priorityTable = {
			AP = {
				"Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
				"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
				"Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Vel'koz", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra",
			},
			Support = {
				"Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean",
			},
			Tank = {
				"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
				"Warwick", "Yorick", "Zac",
			},
			AD_Carry = {
				"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
				"Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo","Zed", 
			},
			Bruiser = {
				"Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
				"Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao",
			},
		}

		--- Arrange Priorities 5v5 ---
--->
	function ArrangePriorities()
		for i, enemy in pairs(enemyHeroes) do
			SetPriority(priorityTable.AD_Carry, enemy, 1)
			SetPriority(priorityTable.AP, enemy, 2)
			SetPriority(priorityTable.Support, enemy, 3)
			SetPriority(priorityTable.Bruiser, enemy, 4)
			SetPriority(priorityTable.Tank, enemy, 5)
		end
	end
---<
--- Arrange Priorities 5v5 ---
--- Arrange Priorities 3v3 ---
--->
	function ArrangeTTPriorities()
		for i, enemy in pairs(enemyHeroes) do
			SetPriority(priorityTable.AD_Carry, enemy, 1)
			SetPriority(priorityTable.AP, enemy, 1)
			SetPriority(priorityTable.Support, enemy, 2)
			SetPriority(priorityTable.Bruiser, enemy, 2)
			SetPriority(priorityTable.Tank, enemy, 3)
		end
	end
---<
--- Arrange Priorities 3v3 ---
--- Set Priorities ---
--->
	function SetPriority(table, hero, priority)
		for i = 1, #table, 1 do
			if hero.charName:find(table[i]) ~= nil then
				TS_SetHeroPriority(priority, hero.charName)
			end
		end
	end

--[[honda]]

function CountObjectsNearPos(pos, radius, objects)
    local n = 0
    for i, object in ipairs(objects) do
        if GetDistanceSqr(pos, object) <= radius * radius then
            n = n + 1
        end
    end
    return n
end

function GetBestCircularFarmPosition(range, radius, objects)
    local BestPos 
    local BestHit = 0
    for i, object in ipairs(objects) do
        local hit = CountObjectsNearPos(object.visionPos or object, radius, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = Vector(object)
            if BestHit == #objects then
               break
            end
         end
    end
    return BestPos, BestHit
end
--

function FarmMinionsW()
	local FarmWithW  = Menu.Farmerr.UseW
	local manaStop 	 = Menu.Farmerr.StopCastMana
	local actualMana = (myPlayer.mana / myPlayer.maxMana *100)
	if FarmWithW == 6 then return end
	MinionsInimigos:update()
	for i, Minion in pairs(MinionsInimigos.objects) do
		--local wDamage = getDmg("W", Minion, myPlayer) * 2
		local BestPos, BestHit = GetBestCircularFarmPosition(TalonRake.range, 400, MinionsInimigos.objects)		
			if BestHit > FarmWithW then --check if number of minion is higher than X
				CastSpell(TalonRake.spellSlot, BestPos.x, BestPos.z)
			end
			--DrawLine1 = BestPos
	end
end

--[[getting pos

function GetPos()
	Posx = mousePos.x
	Posy = mousePos.y
	Posz = mousePos.z
	
	Print1 = tostring(Posx)
	Print2 = tostring(Posy)
	Print3 = tostring(Posz)
end

function OnWndMsg(msg,key)
	if msg == KEY_DOWN and key == string.byte("N") then
		GetPos()
		PrintChat(table.concat({Print1,Print2,Print3},','))
	end
end
]]

