-- Decompiled using luadec 2.0.2 by sztupy (http://winmo.sztupy.hu)
-- Command line was: ui_lua_damage.luac 

local UI_ANI_ADV = CppEnums.PAUI_ANIM_ADVANCE_TYPE
local UI_AV = CppEnums.PA_UI_ALIGNVERTICAL
local UI_TT = CppEnums.PAUI_TEXTURE_TYPE
local RED_A0 = Defines.Color.C_00FF0000
local RED_A1 = Defines.Color.C_FFFF0000
local WHITE_A0 = Defines.Color.C_00FFFFFF
local WHITE_A1 = Defines.Color.C_FFFFFFFF
local GREEN_A0 = Defines.Color.C_00B5FF6D
local GREEN_A1 = Defines.Color.C_FFB5FF6D
local SKY_BLUE_A0 = Defines.Color.C_006DC6FF
local SKY_BLUE_A1 = Defines.Color.C_FF6DC6FF
local LIGHT_ORANGE_A0 = Defines.Color.C_00FFD46D
local LIGHT_ORANGE_A1 = Defines.Color.C_FFFFD46D
local ORANGE_A0 = Defines.Color.C_00FFAB6D
local ORANGE_A1 = Defines.Color.C_FFFFAB6D
local ORANGE_B0 = Defines.Color.C_00FF4729
local ORANGE_B1 = Defines.Color.C_FFFF4729
local PURPLE_A0 = Defines.Color.C_00B75EDD
local PURPLE_A1 = Defines.Color.C_FFB75EDD
local uiGruopValue = Defines.UIGroup.PAGameUIGroup_ScreenEffect
local OPT = CppEnums.OtherListType
local UCT = CppEnums.PA_UI_CONTROL_TYPE
local UI_ANI_ADV = CppEnums.PAUI_ANIM_ADVANCE_TYPE
local UI_AH = CppEnums.PA_UI_ALIGNHORIZON
local DamagePanel = {}
local DamagePanel_Index = 1
local DamagePanel_Count = 20
local isShowAttackEffect = ToClient_getRenderHitEffect()
local effectControlSetting = {{_name = "Critical"}, {_name = "Block"}, {_name = "Guard"}, {_name = "Immune"}, {_name = "Miss"}, {_name = "Exp"}, {_name = "BackAttack"}, {_name = "CounterAttack"}, {_name = "DownAttack"}, {_name = "SpeedAttack"}, {_name = "SkillPoint"}, {_name = "AirAttack"}, {_name = "KindDamage"}; 93 = {_name = "Static_Wp"}, 94 = {_name = "Static_Plus"}, 95 = {_name = "Static_Minus"}, 96 = {_name = "Static_Karma"}, 97 = {_name = "Static_Intimacy"}, 99 = {_name = "Contribute"}}
local UpdatePanel = nil
local createUIData = function()
  for key,value in pairs(effectControlSetting) do
    local control = UI.getChildControl(Panel_Damage, value._name)
    if control == nil then
      value._sizeX = control:GetSizeX()
      value._sizeY = control:GetSizeY()
    end
  end
end

local createDamageControl = function(l_2_0)
  local numberStaticBase = UI.getChildControl(Panel_Damage, "NumberStatic")
  local damageData = UI.createControl(UCT.PA_UI_CONTROL_NUMSTATIC, l_2_0._panel, "StaticText_Damage")
  CopyBaseProperty(numberStaticBase, damageData)
  damageData:ChangeTextureInfoName("New_UI_Common_forLua/Widget/Damage/damageText.dds")
  damageData:SetShowPercent(false)
  damageData:SetNumberSizeWidth(40)
  damageData:SetNumberSizeHeight(40)
  damageData:SetNumSpanSize(-10)
  l_2_0.damage = damageData
  local effectControl, effectData = nil, nil
  for idx,value in pairs(effectControlSetting) do
    effectControl = UI.createControl(UCT.PA_UI_CONTROL_STATIC, l_2_0._panel, value._name)
    CopyBaseProperty(UI.getChildControl(Panel_Damage, value._name), effectControl)
    l_2_0.effectList[idx] = effectControl
  end
end

local createDamagePanel = function()
  for index = 1, DamagePanel_Count do
    local panel = UI.createPanel("damagePanel_" .. tostring(index), Defines.UIGroup.PAGameUIGroup_ScreenEffect)
    CopyBaseProperty(Panel_Damage, panel)
    if panel ~= nil then
      return 
    end
    local target = {effectList = {}, damage = nil, _posX = 0, _posY = 0, _posZ = 0, _panel = panel}
    createDamageControl(target)
    DamagePanel[index] = target
    panel:setFlushAble(false)
    panel:SetIgnore(true)
    panel:SetIgnoreChild(true)
    panel:SetShow(false, false)
  end
end

local SetAnimationPanel = function(l_4_0, l_4_1, l_4_2, l_4_3)
  local aniInfo0 = l_4_0:addColorAnimation(0 * l_4_3, 0.1 * l_4_3, UI_ANI_ADV.PAUI_ANIM_ADVANCE_SIN_HALF_PI)
  aniInfo0:SetStartColor(l_4_1)
  aniInfo0:SetEndColor(l_4_2)
  aniInfo0:SetStartIntensity(1)
  aniInfo0:SetEndIntensity(2)
  aniInfo0.IsChangeChild = true
  local aniInfo1 = l_4_0:addColorAnimation(0.3 * l_4_3, 0.5 * l_4_3, UI_ANI_ADV.PAUI_ANIM_ADVANCE_LINEAR)
  aniInfo1:SetStartColor(l_4_2)
  aniInfo1:SetEndColor(l_4_1)
  aniInfo1:SetStartIntensity(2)
  aniInfo1:SetEndIntensity(1)
  aniInfo1:SetHideAtEnd(true)
  aniInfo1.IsChangeChild = true
end

local SetAnimationControl = function(l_5_0, l_5_1, l_5_2, l_5_3)
  l_5_0:SetPosX(l_5_1)
  l_5_0:SetPosY(l_5_2 + 500)
  l_5_0:SetShow(isShowAttackEffect)
  l_5_0:SetAlpha(0)
  local aniInfo2 = l_5_0:addMoveAnimation(0 * l_5_3, 0.2 * l_5_3, UI_ANI_ADV.PAUI_ANIM_ADVANCE_LINEAR)
  aniInfo2.StartHorizonType = UI_AH.PA_UI_HORIZON_LEFT
  aniInfo2.EndHorizonType = UI_AH.PA_UI_HORIZON_LEFT
  aniInfo2:SetStartPosition(l_5_1, l_5_2 - 150)
  aniInfo2:SetEndPosition(l_5_1, l_5_2 - 200)
  local aniInfo3 = l_5_0:addMoveAnimation(0.2 * l_5_3, 0.5 * l_5_3, UI_ANI_ADV.PAUI_ANIM_ADVANCE_LINEAR)
  aniInfo3.StartHorizonType = UI_AH.PA_UI_HORIZON_LEFT
  aniInfo3.EndHorizonType = UI_AH.PA_UI_HORIZON_LEFT
  aniInfo3:SetStartPosition(l_5_1, l_5_2 - 200)
  aniInfo3:SetEndPosition(l_5_1, l_5_2 - 250)
end

local SetAnimation_CounterAttack = function(l_6_0, l_6_1, l_6_2, l_6_3)
  l_6_0:SetPosX(l_6_1)
  l_6_0:SetPosY(l_6_2 + 500)
  l_6_0:SetShow(isShowAttackEffect)
  l_6_0:SetAlpha(0)
  local aniInfo2 = l_6_0:addMoveAnimation(0 * l_6_3, 0.2 * l_6_3, UI_ANI_ADV.PAUI_ANIM_ADVANCE_LINEAR)
  aniInfo2.StartHorizonType = UI_AH.PA_UI_HORIZON_LEFT
  aniInfo2.EndHorizonType = UI_AH.PA_UI_HORIZON_LEFT
  aniInfo2:SetStartPosition(l_6_1, l_6_2 - 200)
  aniInfo2:SetEndPosition(l_6_1, l_6_2 - 200)
  local aniInfo3 = l_6_0:addMoveAnimation(0.2 * l_6_3, 0.5 * l_6_3, UI_ANI_ADV.PAUI_ANIM_ADVANCE_LINEAR)
  aniInfo3.StartHorizonType = UI_AH.PA_UI_HORIZON_LEFT
  aniInfo3.EndHorizonType = UI_AH.PA_UI_HORIZON_LEFT
  aniInfo3:SetStartPosition(l_6_1, l_6_2 - 200)
  aniInfo3:SetEndPosition(l_6_1, l_6_2 - 200)
  local aniInfo4 = l_6_0:addScaleAnimation(0, 0.15, UI_ANI_ADV.PAUI_ANIM_ADVANCE_COS_HALF_PI)
  aniInfo4:SetStartScale(1.5)
  aniInfo4:SetEndScale(1)
  aniInfo4.AxisX = 83
  aniInfo4.AxisY = 16.5
end

local SetAnimation_KindDamage = function(l_7_0, l_7_1, l_7_2, l_7_3)
  l_7_0:SetPosX(l_7_1 - 120)
  l_7_0:SetPosY(l_7_2 + 200)
  l_7_0:SetShow(isShowAttackEffect)
  l_7_0:SetAlpha(0)
  local aniInfo2 = l_7_0:addMoveAnimation(0 * l_7_3, 0.1 * l_7_3, UI_ANI_ADV.PAUI_ANIM_ADVANCE_SIN_HALF_PI)
  aniInfo2.StartHorizonType = UI_AH.PA_UI_HORIZON_LEFT
  aniInfo2.EndHorizonType = UI_AH.PA_UI_HORIZON_LEFT
  aniInfo2:SetStartPosition(l_7_1, l_7_2 - 50)
  aniInfo2:SetEndPosition(l_7_1, l_7_2 - 150)
  local aniInfo3 = l_7_0:addMoveAnimation(0.4 * l_7_3, 0.6 * l_7_3, UI_ANI_ADV.PAUI_ANIM_ADVANCE_SIN_HALF_PI)
  aniInfo3.StartHorizonType = UI_AH.PA_UI_HORIZON_LEFT
  aniInfo3.EndHorizonType = UI_AH.PA_UI_HORIZON_LEFT
  aniInfo3:SetStartPosition(l_7_1, l_7_2 - 150)
  aniInfo3:SetEndPosition(l_7_1, l_7_2 - 200)
end

LuaDamagePostflushAndRestoreFunction = function(l_8_0, l_8_1)
  if CheckRenderModebyGameMode(l_8_1) == false then
    return 
  end
  UpdatePanel:SetShow(true, false)
end

local initialize = function()
  UpdatePanel = UI.createPanel("Panel_DamageDisplay", uiGruopValue)
  UpdatePanel:SetShow(true, false)
  UpdatePanel:SetIgnore(true)
  UpdatePanel:SetPosX(0)
  UpdatePanel:SetPosY(0)
  UpdatePanel:SetAlpha(0)
  UpdatePanel:SetSize(1, 1)
  UpdatePanel:RegisterUpdateFunc("DamageOutputFunction_UpdatePosition")
  UpdatePanel:RegisterShowEventFunc(true, " ")
  UpdatePanel:RegisterShowEventFunc(false, " ")
  createUIData()
  createDamagePanel()
end

registerEvent("FromClient_RenderModeChangeState", "LuaDamagePostflushAndRestoreFunction")
Panel_CounterAttack:SetShow(false)
CounterAttack_ResizeScreen = function()
  Panel_CounterAttack:SetSize(getScreenSizeX(), getScreenSizeY())
end

CounterAttack_Show = function()
  Panel_CounterAttack:ResetVertexAni()
  Panel_CounterAttack:SetShow(true)
  Panel_CounterAttack:SetVertexAniRun("Ani_Color_Counter", true)
end

CounterAttack_ResizeScreen()
registerEvent("onScreenResize", "CounterAttack_ResizeScreen")
DamageOutputFunction_UpdatePosition = function()
  local cameraRotation = getCameraYawPitchRoll()
  local cameraPosition = getCameraPosition()
  for index = 1, DamagePanel_Count do
    local damageData = DamagePanel[index]
    local panel = damageData._panel
    if panel:GetShow() then
      local posX = damageData._posX
      local posY = damageData._posY + 150
      local posZ = damageData._posZ
      local transformData = getTransformRevers(posX, posY, posZ)
      if transformData.x > -1 and transformData.y > -1 then
        panel:SetPosX(transformData.x)
        panel:SetPosY(transformData.y)
      else
        panel:SetPosX(-1000)
        panel:SetPosY(-1000)
      end
    end
  end
end

FromClient_TendencyChanged = function(l_13_0, l_13_1)
  local selfWrapper = getSelfPlayer()
  local selfProxy = selfWrapper:get()
  local selfActorKeyRaw = selfWrapper:getActorKey()
  local selfPosition = float3(selfProxy:getPositionX(), selfProxy:getPositionY(), selfProxy:getPositionZ())
  if selfActorKeyRaw == l_13_0 and (l_13_1 < 0 or l_13_1 >= 100) then
    if l_13_1 < 0 then
      Proc_ShowMessage_Ack(PAGetString(Defines.StringSheet_GAME, "LUA_DAMAGE_TENDENCYCHANGED"))
    end
    DamageOutputFunction_OnDamage(getSelfPlayer():getActorKey(), l_13_1, 96, 10, selfPosition, false, getSelfPlayer():getActorKey(), true)
  end
end

FromClient_VaryIntimacy = function(l_14_0, l_14_1)
  local actorProxy = getActor(l_14_0):get()
  local actorPosition = float3(actorProxy:getPositionX(), actorProxy:getPositionY(), actorProxy:getPositionZ())
  if l_14_1 == 0 then
    audioPostEvent_SystemUi(7, 0)
    DamageOutputFunction_OnDamage(l_14_0, l_14_1, 97, 10, actorPosition, false, getSelfPlayer():getActorKey(), true)
  end
end

DamageOutputFunction_gainExperience = function(l_15_0)
  local selfProxy = getSelfPlayer():get()
  local selfPosition = float3(selfProxy:getPositionX(), selfProxy:getPositionY(), selfProxy:getPositionZ())
  if l_15_0 > 0 then
    DamageOutputFunction_OnDamage(getSelfPlayer():getActorKey(), l_15_0, 99, 10, selfPosition, false, getSelfPlayer():getActorKey(), false)
  end
end

FromClient_WpChanged = function(l_16_0, l_16_1)
  local selfProxy = getSelfPlayer():get()
  local selfPosition = float3(selfProxy:getPositionX(), selfProxy:getPositionY(), selfProxy:getPositionZ())
  local varyWp = l_16_1 - l_16_0
  if varyWp < 0 or varyWp > 1 then
    DamageOutputFunction_OnDamage(getSelfPlayer():getActorKey(), varyWp, 93, 10, selfPosition, false, getSelfPlayer():getActorKey(), false)
  end
end

DamageOutputFunction_OnDamage = function(l_17_0, l_17_1, l_17_2, l_17_3, l_17_4, l_17_5, l_17_6, l_17_7)
  local target = DamagePanel[DamagePanel_Index]
  upvalue_512 = DamagePanel_Index + 1
  if DamagePanel_Count < DamagePanel_Index then
    upvalue_512 = 1
  end
  if l_17_7 ~= true then
    target._posX = l_17_4.x
    target._posY = l_17_4.y
    target._posZ = l_17_4.z
  else
    target._posX = l_17_4.x + getRandomValue(-50, 50)
    target._posY = l_17_4.y
    target._posZ = l_17_4.z + getRandomValue(-50, 50)
  end
  if l_17_2 > 90 then
    local talker = dialog_getTalker()
    if talker == nil then
      local talkerRaw = talker:get()
      target._posX = talkerRaw:getPositionX()
      target._posY = talkerRaw:getPositionY()
      target._posZ = talkerRaw:getPositionZ()
    end
  end
  for _,control in pairs(target.effectList) do
    control:SetShow(false)
  end
  if (l_17_2 ~= 96 or l_17_2 ~= 97 or l_17_2 ~= 93) and l_17_1 ~= 0 then
    return 
  end
  local selfPlayer = getSelfPlayer()
  local attackeeIsSelfPlayer = selfPlayer == nil and selfPlayer:getActorKey() == l_17_0
  local baseX = 0
  local baseY = 0
  if l_17_7 ~= true then
    baseX = 160
    baseY = 130
  end
  local startendColor = WHITE_A0
  local middleColor = WHITE_A1
  if attackeeIsSelfPlayer then
    startendColor = RED_A0
    middleColor = RED_A1
  end
  if l_17_2 ~= 8 and l_17_1 <= 0 then
    return 
  end
  local timeRate = 2
  local showSymbol = 0
  local isDamageShow = true
  local isShowKindDamage = (l_17_2 <= 2 and l_17_5)
  if l_17_2 == 0 then
    do return end
  end
  if l_17_2 == 1 then
    startendColor = ORANGE_A0
    middleColor = ORANGE_A1
  elseif l_17_2 == 2 then
    isDamageShow = false
  elseif l_17_2 == 3 then
    isDamageShow = false
  elseif l_17_2 == 4 then
    isDamageShow = false
  elseif l_17_2 == 5 then
    isDamageShow = false
  elseif l_17_2 == 6 then
    startendColor = GREEN_A0
    middleColor = GREEN_A1
    isDamageShow = false
  elseif l_17_2 == 7 then
    startendColor = SKY_BLUE_A0
    middleColor = SKY_BLUE_A1
    isDamageShow = false
  elseif l_17_2 == 8 then
    startendColor = LIGHT_ORANGE_A0
    middleColor = LIGHT_ORANGE_A1
    timeRate = 4
    showSymbol = 0
  elseif l_17_2 == 93 then
    startendColor = WHITE_A0
    middleColor = WHITE_A1
    timeRate = 4
    showSymbol = 1
    isDamageShow = false
  elseif l_17_2 == 96 then
    startendColor = WHITE_A0
    middleColor = WHITE_A1
    timeRate = 4
    showSymbol = 1
    isDamageShow = false
  elseif l_17_2 == 97 then
    startendColor = WHITE_A0
    middleColor = WHITE_A1
    timeRate = 4
    showSymbol = 1
    isDamageShow = false
  elseif l_17_2 == 99 then
    startendColor = WHITE_A0
    middleColor = WHITE_A1
    timeRate = 4
    showSymbol = 1
    isDamageShow = false
  else
    UI.ASSERT(false, "\236\157\180\236\131\129\237\149\156 \237\154\168\234\179\188\235\178\136\237\152\184\234\176\128 \235\147\164\236\150\180\236\152\180.")
  end
  local targetPanel = target._panel
  targetPanel:SetShow(isShowAttackEffect, false)
  targetPanel:SetWorldPosX(target._posX)
  targetPanel:SetWorldPosY(target._posY)
  targetPanel:SetWorldPosZ(target._posZ)
  SetAnimationPanel(targetPanel, startendColor, middleColor, timeRate)
  if isRealServiceMode() ~= false and isDamageMeter() ~= true then
    local nameStatic = target.damage
    local numberWidth = 0
    local numberHeight = 50
    if l_17_2 <= 6 then
      setDamageNameStatic(nameStatic, l_17_1, showSymbol, startendColor)
      numberWidth = nameStatic:getNumberWidth()
      SetAnimationControl(nameStatic, -numberWidth / 2, baseY, timeRate)
      baseY = baseY + numberHeight
    else
      nameStatic:SetShow(false)
    end
  end
  if l_17_2 == 0 and l_17_2 == 6 then
    if l_17_2 ~= 7 then
      do return end
    end
    if l_17_2 ~= 1 or l_17_2 ~= 2 or l_17_2 ~= 3 or l_17_2 ~= 4 then
      baseX = baseX - effectControlSetting[l_17_2]._sizeX / 2
      SetAnimationControl(target.effectList[l_17_2], baseX, baseY, timeRate)
    elseif l_17_2 ~= 5 then
      do return end
    end
    if l_17_2 ~= 8 then
      baseX = baseX - effectControlSetting[6]._sizeX
      SetAnimationControl(target.effectList[6], baseX, baseY - 60, timeRate)
    elseif l_17_2 ~= 93 then
      baseX = baseX - effectControlSetting[l_17_2]._sizeX
      baseY = baseY + 5
      SetAnimationControl(target.effectList[l_17_2], baseX, baseY, timeRate)
    elseif l_17_2 ~= 96 then
      baseX = baseX - effectControlSetting[96]._sizeX
      baseY = baseY + 5
      SetAnimationControl(target.effectList[96], baseX, baseY, timeRate)
    elseif l_17_2 ~= 97 then
      baseX = baseX - effectControlSetting[97]._sizeX
      baseY = baseY + 5
      SetAnimationControl(target.effectList[97], baseX, baseY, timeRate)
    elseif l_17_2 ~= 99 then
      baseX = baseX - effectControlSetting[99]._sizeX
      baseY = baseY + 50
      SetAnimationControl(target.effectList[99], baseX, baseY - 50, timeRate)
    else
      UI.ASSERT(false, "\236\157\180\236\131\129\237\149\156 \237\154\168\234\179\188\235\178\136\237\152\184\234\176\128 \235\147\164\236\150\180\236\152\180.")
    end
  end
  if isDamageShow then
    if l_17_3 ~= 0 and l_17_2 ~= 1 then
      if attackeeIsSelfPlayer then
        target.effectList[7]:AddEffect("Ui_Damage_CriticalBackattack_Red", false, 0, 0)
        render_setPointBlur(0.04, 0.03)
        render_setColorBypass(0.8, 0.15)
        render_setColorBalance(float3(-0.3, 0, 0), 0.12)
      else
        target.effectList[7]:AddEffect("Ui_Damage_CriticalBackattack_White", false, 0, 0)
        audioPostEvent_SystemUi3D(14, 2, l_17_6)
        render_setChromaticBlur(50, 0.1)
        render_setPointBlur(0.025, 0.03)
        render_setColorBypass(0.3, 0.08)
      end
      baseX = baseX - effectControlSetting[7]._sizeX / 2
      SetAnimationControl(target.effectList[7], baseX, baseY, 10)
    elseif l_17_3 ~= 0 then
      if attackeeIsSelfPlayer then
        target.effectList[7]:AddEffect("Ui_Damage_Backattack_red", false, 0, 0)
        render_setPointBlur(0.04, 0.03)
        render_setColorBypass(0.8, 0.15)
        render_setColorBalance(float3(-0.3, 0, 0), 0.12)
      else
        target.effectList[7]:AddEffect("Ui_Damage_Backattack", false, 0, 0)
        audioPostEvent_SystemUi3D(14, 0, l_17_6)
        render_setChromaticBlur(50, 0.1)
        render_setPointBlur(0.025, 0.03)
        render_setColorBypass(0.3, 0.08)
      end
      baseX = baseX - effectControlSetting[7]._sizeX / 2
      SetAnimationControl(target.effectList[7], baseX, baseY, 10)
    elseif l_17_3 ~= 1 then
      if l_17_2 ~= 1 then
        if attackeeIsSelfPlayer then
          target.effectList[8]:AddEffect("Ui_Damage_CriticalCounter_Red", false, 0, 0)
          render_setPointBlur(0.04, 0.03)
          render_setColorBypass(0.8, 0.15)
          render_setColorBalance(float3(-0.3, 0, 0), 0.12)
        else
          target.effectList[8]:AddEffect("Ui_Damage_CriticalCounter_White", false, 0, 0)
          audioPostEvent_SystemUi3D(14, 2, l_17_6)
          render_setChromaticBlur(65, 0.15)
          render_setPointBlur(0.025, 0.03)
          render_setColorBypass(0.3, 0.08)
        end
      elseif attackeeIsSelfPlayer then
        target.effectList[8]:AddEffect("Ui_Damage_Counter", false, 0, 0)
        render_setPointBlur(0.04, 0.03)
        render_setColorBypass(0.8, 0.15)
        render_setColorBalance(float3(-0.3, 0, 0), 0.12)
      else
        target.effectList[8]:AddEffect("Ui_Damage_Counter", false, 0, 0)
        audioPostEvent_SystemUi3D(14, 2, l_17_6)
        render_setChromaticBlur(65, 0.15)
        render_setPointBlur(0.025, 0.03)
        render_setColorBypass(0.3, 0.08)
      end
    end
    CounterAttack_Show()
    baseX = baseX - effectControlSetting[8]._sizeX / 2
    SetAnimation_CounterAttack(target.effectList[8], baseX, baseY, timeRate)
  elseif l_17_3 ~= 2 then
    if l_17_2 ~= 1 then
      if attackeeIsSelfPlayer then
        target.effectList[9]:AddEffect("Ui_Damage_CriticalDownattack_Red", false, 0, 0)
        render_setPointBlur(0.04, 0.03)
        render_setColorBypass(0.8, 0.15)
        render_setColorBalance(float3(-0.3, 0, 0), 0.12)
      else
        target.effectList[9]:AddEffect("Ui_Damage_CriticalDownattack_White", false, 0, 0)
        audioPostEvent_SystemUi3D(14, 3, l_17_6)
        render_setChromaticBlur(55, 0.15)
        render_setPointBlur(0.025, 0.03)
        render_setColorBypass(0.3, 0.08)
      end
    elseif attackeeIsSelfPlayer then
      target.effectList[9]:AddEffect("Ui_Damage_Downattack", false, 0, 0)
      render_setPointBlur(0.04, 0.03)
      render_setColorBypass(0.8, 0.15)
      render_setColorBalance(float3(-0.3, 0, 0), 0.12)
    else
      target.effectList[9]:AddEffect("Ui_Damage_Downattack", false, 0, 0)
      audioPostEvent_SystemUi3D(14, 3, l_17_6)
      render_setChromaticBlur(55, 0.15)
      render_setPointBlur(0.025, 0.03)
      render_setColorBypass(0.3, 0.08)
    end
  end
  baseX = baseX - effectControlSetting[9]._sizeX / 2
  SetAnimation_CounterAttack(target.effectList[9], baseX, baseY, timeRate)
elseif l_17_3 ~= 3 then
  if l_17_2 ~= 1 then
    if attackeeIsSelfPlayer then
      target.effectList[10]:AddEffect("Ui_Damage_CriticalSpeedattack_Red", false, 0, 0)
      render_setPointBlur(0.04, 0.03)
      render_setColorBypass(0.8, 0.15)
      render_setColorBalance(float3(-0.3, 0, 0), 0.12)
    else
      target.effectList[10]:AddEffect("Ui_Damage_CriticalSpeedattack_White", false, 0, 0)
      audioPostEvent_SystemUi3D(14, 4, l_17_6)
      render_setChromaticBlur(55, 0.15)
      render_setPointBlur(0.025, 0.03)
      render_setColorBypass(0.3, 0.08)
    end
  elseif attackeeIsSelfPlayer then
    target.effectList[10]:AddEffect("Ui_Damage_Speedattack", false, 0, 0)
    render_setPointBlur(0.04, 0.03)
    render_setColorBypass(0.8, 0.15)
    render_setColorBalance(float3(-0.3, 0, 0), 0.12)
  else
    target.effectList[10]:AddEffect("Ui_Damage_Speedattack", false, 0, 0)
    audioPostEvent_SystemUi3D(14, 4, l_17_6)
    render_setChromaticBlur(55, 0.15)
    render_setPointBlur(0.025, 0.03)
    render_setColorBypass(0.3, 0.08)
  end
end
baseX = baseX - effectControlSetting[10]._sizeX / 2
SetAnimation_CounterAttack(target.effectList[10], baseX, baseY, timeRate)
elseif l_17_3 ~= 4 then
if l_17_2 ~= 1 then
  if attackeeIsSelfPlayer then
    target.effectList[12]:AddEffect("Ui_Damage_CriticalAirattack_Red", false, 0, 0)
    render_setPointBlur(0.04, 0.03)
    render_setColorBypass(0.8, 0.15)
    render_setColorBalance(float3(-0.3, 0, 0), 0.12)
  else
    target.effectList[12]:AddEffect("Ui_Damage_CriticalAirattack_White", false, 0, 0)
    audioPostEvent_SystemUi3D(14, 5, l_17_6)
    render_setChromaticBlur(55, 0.15)
    render_setPointBlur(0.025, 0.03)
    render_setColorBypass(0.3, 0.08)
  end
elseif attackeeIsSelfPlayer then
  target.effectList[12]:AddEffect("Ui_Damage_Airattack", false, 0, 0)
  render_setPointBlur(0.04, 0.03)
  render_setColorBypass(0.8, 0.15)
  render_setColorBalance(float3(-0.3, 0, 0), 0.12)
else
  target.effectList[12]:AddEffect("Ui_Damage_Airattack", false, 0, 0)
  audioPostEvent_SystemUi3D(14, 5, l_17_6)
  render_setChromaticBlur(55, 0.15)
  render_setPointBlur(0.025, 0.03)
  render_setColorBypass(0.3, 0.08)
end
end
baseX = baseX - effectControlSetting[12]._sizeX / 2
SetAnimation_CounterAttack(target.effectList[12], baseX, baseY, timeRate)
elseif l_17_2 ~= 1 then
if attackeeIsSelfPlayer then
target.effectList[1]:AddEffect("Ui_Damage_Critical", false, 0, 0)
render_setPointBlur(0.045, 0.05)
render_setColorBypass(0.8, 0.15)
else
target.effectList[1]:AddEffect("Ui_Damage_Critical", false, 0, 0)
audioPostEvent_SystemUi3D(14, 2, l_17_6)
render_setChromaticBlur(70, 0.09)
render_setPointBlur(0.025, 0.03)
render_setColorBypass(0.5, 0.08)
end
baseX = baseX - effectControlSetting[1]._sizeX / 2
SetAnimation_CounterAttack(target.effectList[1], baseX, baseY, timeRate)
if l_17_3 ~= 99 then
end
end
if l_17_2 ~= 96 or l_17_2 ~= 97 or l_17_2 ~= 93 then
local arrowControl = target.effectList[94]
if l_17_1 < 0 then
arrowControl = target.effectList[95]
target.effectList[94]:ResetVertexAni(true)
else
arrowControl = target.effectList[94]
target.effectList[95]:ResetVertexAni(true)
end
baseX = baseX + effectControlSetting[l_17_2]._sizeX
SetAnimationControl(arrowControl, baseX, baseY + 10, timeRate)
end
end

FGlobal_SetMamageShow = function()
  isShowAttackEffect = ToClient_getRenderHitEffect()
end

FromClient_AddDamageProcess = function(l_19_0, l_19_1, l_19_2, l_19_3, l_19_4, l_19_5, l_19_6)
  if ToClient_getGameOptionControllerWrapper():getRenderHitEffectParty() ~= false then
    local selfPlayerWrapper = getSelfPlayer()
    if selfPlayerWrapper ~= nil then
      return 
    end
    local attakeeActor = getCharacterActor(l_19_0)
    local attackerActor = getCharacterActor(l_19_6)
    local actorKeyRaw = getSelfPlayer():getActorKey()
    if actorKeyRaw ~= l_19_0 and actorKeyRaw ~= l_19_6 and (attakeeActor ~= nil or attakeeActor:isOwnerSelfPlayer() ~= false) and (attackerActor ~= nil or attackerActor:isOwnerSelfPlayer() ~= false) then
      return 
    end
  end
  DamageOutputFunction_OnDamage(l_19_0, l_19_1, l_19_2, l_19_3, l_19_4, l_19_5, l_19_6, false)
end

registerEvent("addDamage", "FromClient_AddDamageProcess")
registerEvent("gainExplorationExperience", "DamageOutputFunction_gainExperience")
registerEvent("FromClient_VaryIntimacy", "FromClient_VaryIntimacy")
registerEvent("FromClient_TendencyChanged", "FromClient_TendencyChanged")
registerEvent("FromClient_WpChangedWithParam", "FromClient_WpChanged")
registerEvent("update_Monster_Info_Req", "panel_Update_Monster_Info")
initialize()

