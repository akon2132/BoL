if myHero.charName ~= "Kalista" then return end

require "VPrediction"
local kalistaScriptConfig, ts, Target, VP
local enemyTable = {}
local enemyCount = 0
local EnemiesK = {}
local Enemies  = GetEnemyHeroes()
local MobsK = {}
local Mobs = minionManager(MINION_ALL, 2500, myHero, MINION_SORT_HEALTH_ASC)
SkillQ = { name = "Pierce", range = 1255, delay = 0.25, speed = 1750, width = 70, ready = false}
SkillW = { name = "Sentinel", range = 5400, delay = 0.25, speed = math.huge, width = 250, ready = false }
SkillE = { name = "Rend", range = 1000, delay = 0.50, speed = nil, width = nil, ready = false }
SkillR = { name = "Fate's Call", range = 1500, delay = nil, speed = nil, width = nil, ready = false }

function OnLoad()
	VP = VPrediction(true)
	Menu()
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1000)
	ts.name = "Focus"
	kalistaScriptConfig:addTS(ts)
	
	for _, unit in pairs(Enemies) do
	table.insert(EnemiesK, {unit = unit, stacks = 0, createTime = 0})
	end
	for i = 1, heroManager.iCount do
		local champ = heroManager:GetHero(i)
		if champ.team ~= player.team then
		enemyCount = enemyCount + 1
		enemyTable[enemyCount] = { player = champ, name = champ.charName, ready = true}
		end
	end
	
	oObject = oObject()
	print("<b><font color=\"#6699FF\">Kalista, The Spear of Vengeance v1.0 :<font color=\"#CCEEFF\"> Loaded!</font></b>")
 end

function OnTick()

	SpellReady()
	Mobs:update()
	if #Mobs.objects ~= #MobsK or (#Mobs.objects > 0 and Mobs.objects[1] ~= MobsK[1].unit) then
	MobsT = {}
    for k,v in pairs(MobsK) do
      table.insert(MobsT, v)
    end   
    MobsK = {}
    for _, minion in pairs(Mobs.objects) do
      local winion = nil
      for _, mob in pairs(MobsT) do
        if mob.unit == minion then winion = mob end
      end
      if winion ~= nil then
        table.insert(MobsK, {unit = minion, stacks = winion.stacks, createTime = winion.createTime})
      else          
        table.insert(MobsK, {unit = minion, stacks = 0, createTime = 0})
      end
    end
	end
	CheckEReadyForKill()
	ts:update()
	Target = GetCustomTarget()
	
	ComboKey = kalistaScriptConfig.menuKeyBindings.comboKey
	HarassKey = kalistaScriptConfig.menuKeyBindings.harassKey
	LaneClearKey = kalistaScriptConfig.menuKeyBindings.laneClearKey
	
	if SkillE.ready and kalistaScriptConfig.menuLaneClear.clearJungle then
		local killableUnit = {}  
		for i, mob in pairs(MobsK) do  
		local EMinionDmg = GetDamageOnEnemies("E", mob.unit, myHero, true)	  
		  if EMinionDmg > mob.unit.health
		  and GetDistance(mob.unit) < SkillE.range
		  and (string.find(mob.unit.charName, "Baron") 
		  or string.find(mob.unit.charName, "Dragon") or string.find(mob.unit.charName, "Gromp") 
		  or (string.find(mob.unit.charName, "Krug")  or string.find(mob.unit.charName, "Murkwolf")
		  or string.find(mob.unit.charName, "Razorbeak")) and not string.find(mob.unit.charName, "Mini"))
		  then table.insert(killableUnit, mob.unit)   
		  end    
		end
		if #killableUnit >= 1 then
			if kalistaScriptConfig.menuMisc.usePacket and VIP_USER then
			Packet("S_CAST", {spellId = _E}):send()
			else
			CastSpell(_E)
			end
		end
	end
	
	if ComboKey then
		Combo(Target)
	end
	
	if HarassKey then
		Harass(Target)
	end
	
	if LaneClearKey then
		LaneClear()
	end
  
end

function OnDraw()
	for i = 1, enemyCount do
      local enemy = enemyTable[i].player
      if ValidTarget(enemy) then
        local barPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
        local posX = barPos.x - 35
        local posY = barPos.y - 50
		dmg = GetDamageOnEnemies("E", enemy, myHero, false)
		local formule1 = math.floor(dmg/enemy.health*100)
		local formule2 = math.ceil((enemy.health-GetDamageOnEnemies("E", enemy, myHero, false)) / (GetDamageOnEnemies("AD", enemy, myHero, false)+(kalE(myHero:GetSpellData(_E).level)+(0.12 + 0.03 * myHero:GetSpellData(_E).level)*myHero.totalDamage)))
		local formule3 = GetDamageOnEnemies("E", enemy, myHero, false)
		if (kalistaScriptConfig.menuDraw.drawEType ~= 4) then if (kalistaScriptConfig.menuDraw.drawEType == 1) then
		 if dmg and dmg > 0 then 
			if formule1 <= 100 then 
				DrawText3D(formule1.."%", enemy.x+125, enemy.y+85, enemy.z+155, 30, ARGB(255,250,250,250), 0)
			else
				DrawText3D("KILLABLE!", enemy.x+125, enemy.y+85, enemy.z+155, 30, ARGB(255,255,128,0), 0)
			end 
		 end
		elseif kalistaScriptConfig.menuDraw.drawEType == 2 then
		 if dmg and dmg > 0 then 
			if formule2 > 0 then
				DrawText3D(formule2.." left",  enemy.x+125, enemy.y+85, enemy.z+155, 30, ARGB(255,250,250,250), 0) 
			else 
				DrawText3D("KILLABLE!", enemy.x+125, enemy.y+85, enemy.z+155, 30, ARGB(255,255,128,0), 0) 
			end 
		end
		elseif kalistaScriptConfig.menuDraw.drawEType == 3 then
		if dmg and dmg > 0 then 
			DrawText3D(math.ceil(formule3).."/".. math.ceil(enemy.health) .. "HP", enemy.x+125, enemy.y+85, enemy.z+155, 30, ARGB({255,250,250,250}), 0)  
		end
		end
		end
	end
end

	if(SkillE.ready) then
			for k,v in pairs(MobsK) do
			if v.stacks > 0 and GetDistance(v.unit) <= 1000 and not v.unit.dead and kalistaScriptConfig.menuDraw.drawEMType == 4 then goto withoutEMT4 end
			if v.stacks > 0 and GetDistance(v.unit) <= 1000 and not v.unit.dead and kalistaScriptConfig.menuDraw.drawEMType ~= 4 then goto withEMT4 end
			::withoutEMT4::
			if v.stacks > 0 and GetDistance(v.unit) <= 1000 and not v.unit.dead then
				dmg = GetDamageOnEnemies("E", v.unit, myHero, true)
				local formule1 = math.floor(dmg/v.unit.health*100)
				local formule2 = math.ceil((v.unit.health-GetDamageOnEnemies("E", v.unit, myHero, true)) / (GetDamageOnEnemies("AD", v.unit, myHero, true)+(kalE(myHero:GetSpellData(_E).level)+(0.12 + 0.03 * myHero:GetSpellData(_E).level)*myHero.totalDamage)))
				local formule3 = dmg
				if v.unit.health < dmg and kalistaScriptConfig.menuDraw.drawKAM then LagFree(v.unit.x, v.unit.y, v.unit.z, 50, 2, ARGB(255,0,255,0), 10) end
			end
			::withEMT4::
			if v.stacks > 0 and GetDistance(v.unit) <= 1000 and not v.unit.dead then
				dmg = GetDamageOnEnemies("E", v.unit, myHero, true)
				local formule1 = math.floor(dmg/v.unit.health*100)
				local formule2 = math.ceil((v.unit.health-GetDamageOnEnemies("E", v.unit, myHero, true)) / (GetDamageOnEnemies("AD", v.unit, myHero, true)+(kalE(myHero:GetSpellData(_E).level)+(0.12 + 0.03 * myHero:GetSpellData(_E).level)*myHero.totalDamage)))
				local formule3 = dmg
			if (kalistaScriptConfig.menuDraw.drawEMType ~= 4) then if (kalistaScriptConfig.menuDraw.drawEMType == 1) then			
				if dmg and dmg > 0 then 
				if formule1 <= 100 then 
					DrawText3D(formule1.."%", v.unit.x+125, v.unit.y+85, v.unit.z+155, 30, ARGB(255,250,250,250), 0)
				else
					 LagFree(v.unit.x, v.unit.y, v.unit.z, 50, 2, ARGB(255,0,255,0), 10)
					--DrawText3D("KILLABLE!", v.unit.x+125, v.unit.y+85, v.unit.z+155, 30, ARGB(255,250,250,250), 0)
				end 
				end
			elseif kalistaScriptConfig.menuDraw.drawEMType == 2 then
				if dmg and dmg > 0 then 
				if formule2 > 0 then
					DrawText3D(formule2.." left", v.unit.x+125, v.unit.y+85, v.unit.z+155, 30, ARGB(255,250,250,250), 0) 
				else 
					 LagFree(v.unit.x, v.unit.y, v.unit.z, 50, 2, ARGB(255,0,255,0), 10)
					--DrawText3D("KILLABLE!", v.unit.x+125, v.unit.y+85, v.unit.z+155, 30, ARGB({255,250,250,250}), 0) 
				end 
				end
			elseif kalistaScriptConfig.menuDraw.drawEMType == 3 then
				if dmg and dmg > 0 then 
					DrawText3D(math.ceil(formule3).."/".. math.ceil(v.unit.health) .. "HP", v.unit.x+125, v.unit.y+85, v.unit.z+155, 30, ARGB({255,250,250,250}), 0)  
				end
			end
			end
			end
		end
	end
	if not (kalistaScriptConfig.menuDraw.disableDraw) then
		if(kalistaScriptConfig.menuDraw.drawAA) then
			if(kalistaScriptConfig.menuDraw.LFC) then
			DrawCircle2(myHero.x,myHero.y,myHero.z,675, RGB(0,255,0))
			else
			DrawCircle(myHero.x,myHero.y,myHero.z, 675, RGB(0,255,0))
			end
		end
		
		if(kalistaScriptConfig.menuDraw.drawQ) then
			if(kalistaScriptConfig.menuDraw.LFC) then
			DrawCircle2(myHero.x,myHero.y,myHero.z,SkillQ.range, RGB(0,255,0))
			else
			DrawCircle(myHero.x,myHero.y,myHero.z,SkillQ.range, RGB(0,255,0))
			end
		end
		if(kalistaScriptConfig.menuDraw.drawW and SkillW.ready) then
			if(kalistaScriptConfig.menuDraw.LFC) then
			DrawCircle2(myHero.x,myHero.y,myHero.z,SkillW.range, ARGB(255, 10, 255, 10))
			else
			DrawCircle(myHero.x,myHero.y,myHero.z,SkillW.range, RGB(0,255,0))
			end
		end
		
		if(kalistaScriptConfig.menuDraw.drawE) then
			if(kalistaScriptConfig.menuDraw.LFC) then
			DrawCircle2(myHero.x,myHero.y,myHero.z,SkillE.range, RGB(0,255,0))
			else
			DrawCircle(myHero.x,myHero.y,myHero.z,SkillE.range, RGB(0,255,0))
			end
		end
		
		if(kalistaScriptConfig.menuDraw.drawR) then
			if(kalistaScriptConfig.menuDraw.LFC) then
			DrawCircle2(myHero.x,myHero.y,myHero.z,SkillR.range, RGB(0,255,0))
			else
			DrawCircle(myHero.x,myHero.y,myHero.z,SkillR.range, RGB(0,255,0))
			end
		end
	end
end
	

function Menu()
	------------------------------MAIN SCREEN-------------------------------------------
	kalistaScriptConfig = scriptConfig("Kalista - The Spear of Vengeance", "kalistaMain")
	------------------------------MENU--------------------------------------------------
	kalistaScriptConfig:addSubMenu("Combo settings", "menuCombo")
	kalistaScriptConfig:addSubMenu("Harass settings", "menuHarass")
	kalistaScriptConfig:addSubMenu("Draw settings", "menuDraw")
	kalistaScriptConfig:addSubMenu("Lane & Jungle Clear settings", "menuLaneClear")
	kalistaScriptConfig:addSubMenu("Misc settings", "menuMisc")
	kalistaScriptConfig:addSubMenu("Key bindings settings", "menuKeyBindings")
	kalistaScriptConfig:addSubMenu("Orbwalking settings","menuOrbwalk")
	---------------------------------COMBO--------------------------------------------------------------------------------------------
	kalistaScriptConfig.menuCombo:addParam("comboQ", "Use "..SkillQ.name.." Q", SCRIPT_PARAM_ONOFF, true)
	--kalistaScriptConfig.menuCombo:addParam("comboW", "Use "..SkillW.name.." W", SCRIPT_PARAM_ONOFF, true)
	kalistaScriptConfig.menuCombo:addParam("comboE", "Use "..SkillE.name.." E", SCRIPT_PARAM_ONOFF, true)
	--kalistaScriptConfig.menuCombo:addParam("comboR", "Use "..SkillR.name.." R", SCRIPT_PARAM_ONOFF, true)
	--------------------------------HARASS--------------------------------------------------------------------------------------------
	kalistaScriptConfig.menuHarass:addParam("harassQ", "Use "..SkillQ.name.." Q", SCRIPT_PARAM_ONOFF, true)
	kalistaScriptConfig.menuHarass:addParam("harassQMANA", "Use Q if mana above %", SCRIPT_PARAM_SLICE, 60,1,100,0)
	--------------------------------LANECLEAR-----------------------------------------------------------------------------------------
	kalistaScriptConfig.menuLaneClear:addParam("clearJungle", "Clear jungle with e",  SCRIPT_PARAM_ONOFF, true)
	kalistaScriptConfig.menuLaneClear:addParam("exMinionE", "Use e for minions",  SCRIPT_PARAM_ONOFF, true)
	kalistaScriptConfig.menuLaneClear:addParam("exMinionIF", "Use E if x minions can be killed", SCRIPT_PARAM_SLICE, 2,1,10,0)
	kalistaScriptConfig.menuLaneClear:addParam("aexMinionIFML", "Use e if mana above %", SCRIPT_PARAM_SLICE, 30,1,100,0)
	------------------------------MISC------------------------------------------------------------------------------------------------
	if VIP_USER then kalistaScriptConfig.menuMisc:addParam("usePacket", "Use PacketCast (VIP)", SCRIPT_PARAM_ONOFF, false)
	else kalistaScriptConfig.menuMisc:addParam("usePacket", "YOU ARE NOT VIP USER ", SCRIPT_PARAM_INFO, "") end
	---------------------------------DRAW---------------------------------------------------------------------------------------------
	kalistaScriptConfig.menuDraw:addParam("disableDraw", "Disable all", SCRIPT_PARAM_ONOFF, false)
	kalistaScriptConfig.menuDraw:addParam("LFC", 	"Lag free circles", SCRIPT_PARAM_ONOFF, false)
	kalistaScriptConfig.menuDraw:addParam("drawAA", "Draw AA range", SCRIPT_PARAM_ONOFF, true)
	kalistaScriptConfig.menuDraw:addParam("drawQ", 	"Draw Q range", SCRIPT_PARAM_ONOFF, true)
	--kalistaScriptConfig.menuDraw:addParam("drawW", 	"Draw W range", SCRIPT_PARAM_ONOFF, true)
	kalistaScriptConfig.menuDraw:addParam("drawE", 	"Draw E range", SCRIPT_PARAM_ONOFF, true)
	kalistaScriptConfig.menuDraw:addParam("drawEType", 	"E Damage type of enemy", SCRIPT_PARAM_LIST, 1, {"Percent", "Attack left", "Total damage", "OFF"})
	kalistaScriptConfig.menuDraw:addParam("drawEMType", 	"E Damage type of minion", SCRIPT_PARAM_LIST, 1, {"Percent", "Attack left", "Total damage", "OFF"})
	kalistaScriptConfig.menuDraw:addParam("drawKAM", 	"Draw killable minions with E", SCRIPT_PARAM_ONOFF, false)
	--kalistaScriptConfig.menuDraw:addParam("drawR", 	"Draw R range", SCRIPT_PARAM_ONOFF, true)
	---------------------------------ORBWALKER----------------------------------------------------------------------------------------
	if _G.Reborn_Loaded == nil and _G.MMA_Loaded == nil then require "SxOrbwalk" SxOrb:LoadToMenu(kalistaScriptConfig.menuOrbwalk) 
	else kalistaScriptConfig.menuOrbwalk:addParam("orbwalkerStatus", "SAC OR MMA", SCRIPT_PARAM_INFO, "DETECTED")  end
	---------------------------------KEYBINDING---------------------------------------------------------------------------------------
	kalistaScriptConfig.menuKeyBindings:addParam("comboKey", 	"Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	kalistaScriptConfig.menuKeyBindings:addParam("harassKey", 	"Harass", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("A"))
	kalistaScriptConfig.menuKeyBindings:addParam("laneClearKey","Lane clear", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
end

function Combo(cTarget)
	--Q cast
	if cTarget ~= nil 
	and GetDistance(cTarget) <= SkillQ.range 
	and kalistaScriptConfig.menuCombo.comboQ	
	and SkillQ.ready 
	then
		local castPos, HitChance, pos = VP:GetLineCastPosition(cTarget, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, true)
			if HitChance >= 2 then
			if kalistaScriptConfig.menuMisc.usePacket and VIP_USER then
			Packet("S_CAST", {spellId = _Q, fromX = castPos.x, fromY = castPos.z, toX = castPos.x, toY = castPos.z}):send()
			else
			CastSpell(_Q, castPos.x, castPos.z)
			end
		end
	end
end

function Harass(hTarget)
	--Q cast with mana controller
	if hTarget ~= nil 
	and GetDistance(hTarget) <= SkillQ.range 
	and kalistaScriptConfig.menuHarass.harassQ 
	and SkillQ.ready 
	and	myHero.mana > (myHero.maxMana*(kalistaScriptConfig.menuHarass.harassQMANA*0.01))
	then
		local castPos, HitChance, pos = VP:GetLineCastPosition(hTarget, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, true)
			if HitChance >= 2 then
			if kalistaScriptConfig.menuMisc.usePacket and VIP_USER then
			Packet("S_CAST", {spellId = _Q, fromX = castPos.x, fromY = castPos.z, toX = castPos.x, toY = castPos.z}):send()
			else
			CastSpell(_Q, castPos.x, castPos.z)
			end
		end
	end
end

function LaneClear()
	--Cast e to the minions
	if (kalistaScriptConfig.menuLaneClear.exMinionE and SkillE.ready) then
    local killableUnit = {}  
    for i, mob in pairs(MobsK) do
		local EMinionDmg = GetDamageOnEnemies("E", mob.unit, myHero, true)     
      if EMinionDmg > mob.unit.health and ValidTarget(mob.unit, SkillE.range) and GetDistance(mob.unit) < SkillE.range then
        table.insert(killableUnit, mob.unit)
      end
    end    
    if #killableUnit >= kalistaScriptConfig.menuLaneClear.exMinionIF 
	and myHero.mana > (myHero.maxMana*(kalistaScriptConfig.menuLaneClear.aexMinionIFML*0.01)) 
	and SkillE.ready then
		if kalistaScriptConfig.menuMisc.usePacket and VIP_USER then
		Packet("S_CAST", {spellId = _E}):send()
		else
		CastSpell(_E)
		end
    end
  end 
end

class "oObject"

function oObject:__init()
  AddCreateObjCallback(function(obj) self:HandleCreateObj(obj) end)
  return self
end

function oObject:HandleCreateObj(obj)
  if obj == nil then return end
  rendTable = {
    ["Kalista_Base_E_Spear_tar1.troy"] = { rend = 1 }, ["Kalista_Base_E_Spear_tar2.troy"] = { rend = 2 }, ["Kalista_Base_E_Spear_tar3.troy"] = { rend = 3 }, 
    ["Kalista_Base_E_Spear_tar4.troy"] = { rend = 4 }, ["Kalista_Base_E_Spear_tar5.troy"] = { rend = 5 }, ["Kalista_Base_E_Spear_tar6.troy"] = { rend = 6 }
  }
  rendTableSkin = {
    ["Kalista_Skin01_E_Spear_tar1.troy"] = { rend = 1 }, ["Kalista_Skin01_E_Spear_tar2.troy"] = { rend = 2 }, ["Kalista_Skin01_E_Spear_tar3.troy"] = { rend = 3 }, 
    ["Kalista_Skin01_E_Spear_tar4.troy"] = { rend = 4 }, ["Kalista_Skin01_E_Spear_tar5.troy"] = { rend = 5 }, ["Kalista_Skin01_E_Spear_tar6.troy"] = { rend = 6 }
  }
  for i, unit in pairs(EnemiesK) do
    if GetDistance(unit.unit,obj) < 80 then
      if rendTable[obj.name] or rendTableSkin[obj.name] then
        unit.stacks = (unit.stacks >= 6 and (unit.stacks+1) or rendTable[obj.name].rend)
        unit.createTime = GetInGameTimer()
      end
      if rendTableSkin[obj.name] then
        unit.stacks = (unit.stacks >= 6 and (unit.stacks+1) or rendTableSkin[obj.name].rend)
        unit.createTime = GetInGameTimer()
      end
    end
  end
    for i, mob in pairs(MobsK) do
    if GetDistance(mob.unit,obj) < 80 then
      if rendTable[obj.name] then
        mob.stacks = (mob.stacks >= 6 and (mob.stacks+1) or rendTable[obj.name].rend)
        mob.createTime = GetInGameTimer()
      end
      if rendTableSkin[obj.name] then
        mob.stacks = (mob.stacks >= 6 and (mob.stacks+1) or rendTableSkin[obj.name].rend)
        mob.createTime = GetInGameTimer()
      end
    end
  end
end
function LagFree(x, y, z, radius, width, color, quality)
    local radius = radius or 300
    local screenMin = WorldToScreen(D3DXVECTOR3(x - radius, y, z + radius))
    if OnScreen({x = screenMin.x + 200, y = screenMin.y + 200}, {x = screenMin.x + 200, y = screenMin.y + 200}) then
        radius = radius*.92
        local quality = quality and 2 * math.pi / quality or 2 * math.pi / math.floor(radius / 10)
        local width = width and width or 1
        local a = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(0), y, z - radius * math.sin(0)))
        for theta = quality, 2 * math.pi + quality, quality do
            local b = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
            DrawLine(a.x, a.y, b.x, b.y, width, color)
            a = b
        end
    end
end
-- Barasia, vadash, viseversa. LOW FPS DROPS-------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------------------------------
function CheckEReadyForKill()
    for i = 1, enemyCount do
        local enemy = enemyTable[i].player
          if ValidTarget(enemy, SkillE.range) and enemy.visible then
			if enemy.health < GetDamageOnEnemies("E", enemy, myHero , false) and kalistaScriptConfig.menuCombo.comboE and SkillE.ready then 
				if kalistaScriptConfig.menuMisc.usePacket and VIP_USER then
				Packet("S_CAST", {spellId = _E}):send()
				else
				CastSpell(_E)
				end 
			end
        end
    end
end
function GetDamageOnEnemies(spell, target, source, mobornot)
  if target == nil or source == nil then
    return
  end
  local ADDmg            = 0
  local APDmg            = 0
  local Level            = source.level
  local TotalDmg         = source.totalDamage
  local ArmorPen         = math.floor(source.armorPen)
  local ArmorPenPercent  = math.floor(source.armorPenPercent*100)/100
  local MagicPen         = math.floor(source.magicPen)
  local MagicPenPercent  = math.floor(source.magicPenPercent*100)/100
  
  local Armor        = target.armor*ArmorPenPercent-ArmorPen
  local ArmorPercent = Armor > 0 and math.floor(Armor*100/(100+Armor))/100 or math.ceil(Armor*100/(100-Armor))/100
  local MagicArmor   = target.magicArmor*MagicPenPercent-MagicPen
  local MagicArmorPercent = MagicArmor/(100+MagicArmor)

  local QLevel, WLevel, ELevel, RLevel = myHero:GetSpellData(_Q).level, myHero:GetSpellData(_W).level, myHero:GetSpellData(_E).level, myHero:GetSpellData(_R).level
  if source ~= myHero then
    return TotalDmg*(1-ArmorPercent)
  end
  if spell == "IGNITE" then
    return 50+20*Level
  elseif spell == "AD" then
    ADDmg = TotalDmg
  elseif spell == "Q" then
    ADDmg = 60*QLevel+10+TotalDmg
  elseif spell == "W" then
    return 0
  elseif spell == "E" then
	stacks = 0
if not mobornot then
	for i, unit in pairs(EnemiesK) do
		if unit.unit == target then
			if unit.createTime + 4 > GetInGameTimer() then
				stacks = unit.stacks
			else
				stacks = 0
				unit.stacks = 0
			end
		end
	end
else
	for i, mob in pairs(MobsK) do
		  if mob.unit == target then
			if mob.createTime + 4 > GetInGameTimer() then
				stacks = mob.stacks
			else
				stacks = 0
				mob.stacks = 0
			end
		end
	end
end
	ADDmg = stacks > 0 and (10 + (10 * ELevel) + (TotalDmg * 0.6)) + (stacks-1) *(kalE(ELevel) + (0.12 + 0.03 * ELevel)*TotalDmg) or 0
	elseif spell == "R" then return 0
  end
	return math.floor(ADDmg * (1-ArmorPercent))
end

function kalE(x)
  if x <= 1 then 
    return 10
  else 
    return kalE(x-1) + 2 + x
  end 
end
function SpellReady()
SkillQ.ready = (myHero:CanUseSpell(_Q) == READY)
SkillW.ready = (myHero:CanUseSpell(_W) == READY)
SkillE.ready = (myHero:CanUseSpell(_E) == READY)
SkillR.ready = (myHero:CanUseSpell(_R) == READY)
end
function GetCustomTarget()
	ts:update()
    if _G.MMA_Target and _G.MMA_Target.type == myHero.type then return _G.MMA_Target end
    if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then return _G.AutoCarry.Attack_Crosshair.target end
    return ts.target
end
