﻿local mod	= VEM:NewMod(869, "VEM-SiegeOfOrgrimmar", nil, 369)
local L		= mod:GetLocalizedStrings()
local sndWOP	= mod:NewSound(nil, "SoundWOP", true)
local sndGC		= mod:NewSound(nil, "SoundGC", mod:IsDps())
local sndNL	= mod:NewSound(nil, "SoundNL", mod:IsTank())

mod:SetRevision(("$Revision: 10700 $"):sub(12, -3))
mod:SetCreatureID(71865)
mod:SetZone()
mod:SetUsedIcons(8, 7)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED",
	"UNIT_DIED",
	"SPELL_INTERRUPT",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"UNIT_SPELLCAST_SUCCEEDED boss1 boss2 boss3 boss4 boss5"--I saw garrosh fire boss1 and boss3 events, so use all 5 to be safe
)

--Stage 1: The True Horde
local warnDesecrate					= mod:NewTargetAnnounce(144748, 3)
local warnHellscreamsWarsong		= mod:NewSpellAnnounce(144821, 3)
local warnFireUnstableIronStar		= mod:NewSpellAnnounce(147047, 3)
local warnFarseerWolfRider			= mod:NewSpellAnnounce("ej8294", 3, 144585)
local warnSiegeEngineer				= mod:NewSpellAnnounce("ej8298", 4, 144616)
local warnChainHeal					= mod:NewSpellAnnounce(144583, 4)
local warnChainLightning			= mod:NewSpellAnnounce(144584, 3, nil, false)--Maybe turn off by default if too spammy
--Intermission: Realm of Y'Shaarj
local warnYShaarjsProtection		= mod:NewTargetAnnounce(144945, 2)
local warnAnnihilate				= mod:NewCastAnnounce(144969, 4)
--Stage Two: Power of Y'Shaarj
local warnPhase2					= mod:NewPhaseAnnounce(2)
local warnWhirlingCorruption		= mod:NewCountAnnounce(144985, 3)
local warnTouchOfYShaarj			= mod:NewTargetAnnounce(145071, 3)
local warnGrippingDespair			= mod:NewStackAnnounce(145183, 2, nil, mod:IsTank())
--Starge Three: MY WORLD
local warnPhase3					= mod:NewPhaseAnnounce(3)
local warnEmpWhirlingCorruption		= mod:NewSpellAnnounce(145037, 3)
local warnEmpTouchOfYShaarj			= mod:NewTargetAnnounce(145175, 3)
local warnEmpGrippingDespair		= mod:NewStackAnnounce(145195, 3, nil, mod:IsTank())--Distinction is not that important, may just remove for the tank warning.
--Starge Four: Heroic Hidden Phase
local warnPhase4					= mod:NewPhaseAnnounce(4)
local warnMalice					= mod:NewTargetAnnounce(147209, 2)
local warnBombardment				= mod:NewSpellAnnounce(147120, 3)
local warnManifestRage				= mod:NewSpellAnnounce(147011, 4)
local warnFixate					= mod:NewTargetAnnounce(147665, 2)

--Stage 1: The True Horde
local specWarnDesecrate				= mod:NewSpecialWarningCount(144748, nil, nil, nil, 2)
local specWarnDesecrateYou			= mod:NewSpecialWarningYou(144748)
local yellDesecrate					= mod:NewYell(144748)
local specWarnHellscreamsWarsong	= mod:NewSpecialWarningSpell(144821, mod:IsTank() or mod:IsHealer())
local specWarnFireUnstableIronStar	= mod:NewSpecialWarningSpell(147047, nil, nil, nil, 3)
local specWarnFarseerWolfRider		= mod:NewSpecialWarningSwitch("ej8294", not mod:IsHealer())
local specWarnSiegeEngineer			= mod:NewSpecialWarningSwitch("ej8298", false)--Only 1 person on 10 man and 2 on 25 needed, so should be off for most of raid
local specWarnChainHeal				= mod:NewSpecialWarningInterrupt(144583)
local specWarnChainLightning		= mod:NewSpecialWarningInterrupt(144584, false)
--Intermission: Realm of Y'Shaarj
local specWarnAnnihilate			= mod:NewSpecialWarningSpell(144969, false, nil, nil, 3)
--Stage Two: Power of Y'Shaarj
local specWarnWhirlingCorruption	= mod:NewSpecialWarningCount(144985)--Two options important, for distinction and setting custom sounds for empowered one vs non empowered one, don't merge

local specWarnGrippingDespair		= mod:NewSpecialWarningStack(145183, mod:IsTank(), 3)--Unlike whirling and desecrate, doesn't need two options, distinction isn't important for tank swaps.
local specWarnGrippingDespairOther	= mod:NewSpecialWarningTarget(145183, mod:IsTank())
local specWarnTouchOfYShaarj		= mod:NewSpecialWarningSwitch(145071)
local specWarnTouchInterrupt		= mod:NewSpecialWarningCount(149347)
--Starge Three: MY WORLD
local specWarnEmpWhirlingCorruption	= mod:NewSpecialWarningCount(145037)--Two options important, for distinction and setting custom sounds for empowered one vs non empowered one, don't merge
local specWarnEmpDesecrate			= mod:NewSpecialWarningCount(144749, nil, nil, nil, 2)--^^
--Starge Four: Heroic Hidden Phase
local specWarnMaliceYou				= mod:NewSpecialWarningYou(147209)
local yellMalice					= mod:NewYell(147209)
local specWarnBombardment			= mod:NewSpecialWarningCount(147120, nil, nil, nil, 2)
local specWarnFixateYou				= mod:NewSpecialWarningYou(147665)

--Stage 1: A Cry in the Darkness
local timerDesecrateCD				= mod:NewCDCountTimer(35, 144748)
local timerHellscreamsWarsongCD		= mod:NewNextTimer(42.2, 144821, nil, mod:IsTank() or mod:IsHealer())
local timerFarseerWolfRiderCD		= mod:NewNextTimer(50, "ej8294", nil, nil, nil, 144585)--EJ says they come faster as phase progresses but all i saw was 3 spawn on any given pull and it was 30 50 50
local timerSiegeEngineerCD			= mod:NewNextTimer(40, "ej8298", nil, nil, nil, 144616)
local timerPowerIronStar			= mod:NewCastTimer(15, 144616)
--Intermission: Realm of Y'Shaarj
local timerEnterRealm				= mod:NewNextTimer(145.5, 144866, nil, nil, nil, 144945)
local timerYShaarjsProtection		= mod:NewBuffActiveTimer(61, "ej8305", nil, nil, nil, 144945)--May be too long, but intermission makes more sense than protection buff which actually fades before intermission ends if you do it right.
--Stage Two: Power of Y'Shaarj
local timerWhirlingCorruptionCD		= mod:NewCDCountTimer(49.5, 9633)--One bar for both, "empowered" makes timer too long. CD not yet known except for first
local timerWhirlingCorruption		= mod:NewBuffActiveTimer(9, 9633)
local timerTouchOfYShaarjCD			= mod:NewCDCountTimer(45, 15690)
local timerGrippingDespair			= mod:NewTargetTimer(15, 145183, nil, mod:IsTank())
--Starge Three: MY WORLD
--Starge Four: Heroic Hidden Phase
local timerMaliceCD					= mod:NewNextTimer(29.5, 147209)
local timerBombardmentCD			= mod:NewNextTimer(55, 147120)
local timerBombardment				= mod:NewBuffActiveTimer(13, 147120)
local timerFixate					= mod:NewBuffFadesTimer(10, 147665)

--local soundWhirlingCorrpution		= mod:NewSound(144985, nil, false)--Depends on strat. common one on 25 man is to never run away from it
--local countdownPowerIronStar		= mod:NewCountdown(15, 144616)
--local countdownWhirlingCorruption	= mod:NewCountdown(49.5, 144985)
--local countdownTouchOfYShaarj		= mod:NewCountdown(45, 145071, false, nil, nil, nil, true)--Off by default only because it's a cooldown and it does have a 45-48sec variation

mod:AddBoolOption("SetIconOnShaman")

local touchOfYShaarjTargets = {}
local adds = {}
local scanLimiter = 0
local firstIronStar = false
local engineerDied = 0
local phase = 1
local UnitExists = UnitExists
local whirlCount = 0
local desecrateCount = 0
local mindControlCount = 0
local shamanAlive = 0
local Ancount = 0
local Xfcount = 0
local EXfcount = 0
local Tqcount = 0
local ERcount = 0
local Bombcount = 0
local EYcount = 0
local Touchcount = {}

local function scanForMobs()
	if VEM:GetRaidRank() > 0 then
		scanLimiter = scanLimiter + 1
		for uId in VEM:GetGroupMembers() do
			local unitid = uId.."target"
			local guid = UnitGUID(unitid)
			local cid = mod:GetCIDFromGUID(guid)
			if cid == 71983 and guid and not adds[guid] then
				if shamanAlive == 1 then
					SetRaidTarget(unitid, 8)
				else--We are behind on them, so use X instead of skull
					SetRaidTarget(unitid, 7)
				end
				adds[guid] = true
				return
			end
		end
		local guid2 = UnitGUID("mouseover")
		local cid = mod:GetCIDFromGUID(guid2)
		if cid == 71983 and guid2 and not adds[guid2] then
			if shamanAlive == 1 then
				SetRaidTarget("mouseover", 8)
			else--We are behind on them, so use X instead of skull
				SetRaidTarget("mouseover", 7)
			end
			adds[guid2] = true
			return
		end
		if scanLimiter < 40 then--Don't scan for more than 8 seconds
			mod:Schedule(0.2, scanForMobs)
		end
	end
end

local healcount = 0
local shmddcount = 0
local needwarnin = false


mod:AddBoolOption("LTIP", true, "sound")

mod:AddDropdownOption("optDD", {"alldd", "DD1", "DD2", "DD1H", "DD2H", "DD3H", "DD4H", "nodd"}, "alldd", "sound")

mod:AddEditBoxOption("TQcount", 50, "", "sound", 
function()
	if mod.Options.TQcount == "" then return end
	local checknum = tonumber(mod.Options.TQcount)	
	if type(checknum) == "number" then
		VEM:AddMsg("["..L.nameset.."]".."|cFF00FF00"..mod.localization.options["TQcount"]..VEM_CORE_SETTO..checknum.."|r")
	else
		VEM:AddMsg("["..L.nameset.."]"..VEM_CORE_WRONGSET.."\""..mod.Options.TQcount.."\"")
		VEM:AddMsg("["..L.nameset.."]"..VEM_CORE_WRONGSET.."\""..mod.Options.TQcount.."\"")
		VEM:AddMsg("["..L.nameset.."]"..VEM_CORE_WRONGSET.."\""..mod.Options.TQcount.."\"")
	end
end)

mod:AddEditBoxOption("ANcount", 50, "", "sound", 
function()
	if mod.Options.ANcount == "" then return end
	local checknum = tonumber(mod.Options.ANcount)	
	if type(checknum) == "number" then
		VEM:AddMsg("["..L.nameset.."]".."|cFF00FF00"..mod.localization.options["ANcount"]..VEM_CORE_SETTO..checknum.."|r")
	else
		VEM:AddMsg("["..L.nameset.."]"..VEM_CORE_WRONGSET.."\""..mod.Options.ANcount.."\"")
		VEM:AddMsg("["..L.nameset.."]"..VEM_CORE_WRONGSET.."\""..mod.Options.ANcount.."\"")
		VEM:AddMsg("["..L.nameset.."]"..VEM_CORE_WRONGSET.."\""..mod.Options.ANcount.."\"")
	end
end)

mod:AddEditBoxOption("XFcount", 50, "", "sound", 
function()
	if mod.Options.XFcount == "" then return end
	local checknum = tonumber(mod.Options.XFcount)	
	if type(checknum) == "number" then
		VEM:AddMsg("["..L.nameset.."]".."|cFF00FF00"..mod.localization.options["XFcount"]..VEM_CORE_SETTO..checknum.."|r")
	else
		VEM:AddMsg("["..L.nameset.."]"..VEM_CORE_WRONGSET.."\""..mod.Options.XFcount.."\"")
		VEM:AddMsg("["..L.nameset.."]"..VEM_CORE_WRONGSET.."\""..mod.Options.XFcount.."\"")
		VEM:AddMsg("["..L.nameset.."]"..VEM_CORE_WRONGSET.."\""..mod.Options.XFcount.."\"")
	end
end)

mod:AddEditBoxOption("EXFcount", 50, "", "sound", 
function()
	if mod.Options.EXFcount == "" then return end
	local checknum = tonumber(mod.Options.EXFcount)	
	if type(checknum) == "number" then
		VEM:AddMsg("["..L.nameset.."]".."|cFF00FF00"..mod.localization.options["EXFcount"]..VEM_CORE_SETTO..checknum.."|r")
	else
		VEM:AddMsg("["..L.nameset.."]"..VEM_CORE_WRONGSET.."\""..mod.Options.EXFcount.."\"")
		VEM:AddMsg("["..L.nameset.."]"..VEM_CORE_WRONGSET.."\""..mod.Options.EXFcount.."\"")
		VEM:AddMsg("["..L.nameset.."]"..VEM_CORE_WRONGSET.."\""..mod.Options.EXFcount.."\"")
	end
end)


local function MyJS(spell)
	local spellnum = 0
	local checknum = 0
	if spell == "AN" then
		spellnum = mod.Options.ANcount
		checknum = Ancount
	elseif spell == "XF" then
		spellnum = mod.Options.XFcount
		checknum = Xfcount
	elseif spell == "EXF" then
		spellnum = mod.Options.EXFcount
		checknum = EXfcount
	elseif spell == "TQ" then
		spellnum = mod.Options.TQcount
		checknum = Tqcount
	end
	spellnum = tonumber(spellnum)
	if checknum == spellnum then
		return true
	end
	return false
end

local function checknexttouchOfYShaarj(spell)
	local _, _, touchtime = timerTouchOfYShaarjCD:GetTime()
	local _, _, whirlingtime = timerWhirlingCorruptionCD:GetTime()
	local _, _, desecratetime = timerWhirlingCorruptionCD:GetTime()
	if (spell == "desecrate") and (touchtime ~= 0) and (whirlingtime ~= 0) then
		if touchtime < whirlingtime then
			print("test: 下一個技能是心控")
		else
			print("test: 下一個技能是旋風")
		end
	elseif (spell == "whirling") and (touchtime ~= 0) and (desecratetime ~= 0) then
		if touchtime < desecratetime then
			print("test: 下一個技能是心控")
		else
			print("test: 下一個技能是武器")
		end
	end
end

local function warnTouchOfYShaarjTargets(spellId)
	if spellId == 145171 then
		warnEmpTouchOfYShaarj:Show(table.concat(touchOfYShaarjTargets, "<, >"))
	else
		warnTouchOfYShaarj:Show(table.concat(touchOfYShaarjTargets, "<, >"))
	end
	table.wipe(touchOfYShaarjTargets)
end

function mod:DesecrateTarget(targetname, uId)
	if not targetname then return end
	if self:IsTanking(uId) then return end--Never targets tanks
	warnDesecrate:Show(targetname)
	if targetname == UnitName("player") then
		specWarnDesecrateYou:Show()
		yellDesecrate:Yell()
	end
end

function mod:OnCombatStart(delay)
	firstIronStar = false
	engineerDied = 0
	phase = 1
	whirlCount = 0
	desecrateCount = 0
	mindControlCount = 0
	shamanAlive = 0
	healcount = 0
	shmddcount = 0
	Ancount = 0
	Xfcount = 0
	EXfcount = 0
	Tqcount = 0
	ERcount = 0
	Bombcount = 0
	EYcount = 0
	needwarnin = false
	table.wipe(touchOfYShaarjTargets)
	table.wipe(adds)
	table.wipe(Touchcount)
	timerDesecrateCD:Start(10.5-delay, 1)
	timerSiegeEngineerCD:Start(20-delay)
	sndGC:Schedule(15, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_gczb.mp3") --攻城師準備
	timerHellscreamsWarsongCD:Start(22-delay)
	if not mod:IsDps() then
		sndWOP:Schedule(19, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_zgzb.mp3") --戰歌準備
	end
	timerFarseerWolfRiderCD:Start(30-delay)
	if not mod:IsHealer() then
		sndWOP:Schedule(25, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_lqzb.mp3") --狼騎兵準備
	end
end

function mod:OnCombatEnd()
	self:UnregisterShortTermEvents()
	if self.Options.LTIP then
		VEM:HideLTSpecialWarning()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 144583 then
		local source = args.sourceName
		warnChainHeal:Show()
		healcount = healcount + 1
		if ((mod.Options.optDD == "DD1") and (healcount == 1)) or ((mod.Options.optDD == "DD2") and (healcount == 2)) or ((mod.Options.optDD == "alldd") and (source == UnitName("target") or source == UnitName("focus"))) then
			specWarnChainHeal:Show(source)
			sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\interruptsoon.mp3")
			sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\kickcast.mp3") --快打斷
		end
		if ((mod.Options.optDD == "DD1") and (healcount == 2)) or ((mod.Options.optDD == "DD2") and (healcount == 1)) then
			sndWOP:Schedule(7, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\interruptsoon.mp3") --打斷準備
		end
		if healcount == 2 then healcount = 0 end
		shmddcount = shmddcount + 1
		if ((mod.Options.optDD == "DD1H") and (shmddcount % 4 == 1)) or ((mod.Options.optDD == "DD2H") and (shmddcount % 4 == 2)) or ((mod.Options.optDD == "DD3H") and (shmddcount % 4 == 3)) or ((mod.Options.optDD == "DD4H") and (shmddcount % 4 == 0))	then
			specWarnChainHeal:Show(source)
			sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\kickcast.mp3") --快打斷
		end
	elseif args.spellId == 144584 then
		local source = args.sourceName
		warnChainLightning:Show()
--		if source == UnitName("target") or source == UnitName("focus") then 
--			specWarnChainLightning:Show(source)
--		end		
		shmddcount = shmddcount + 1
		if ((mod.Options.optDD == "DD1H") and (shmddcount % 4 == 1)) or ((mod.Options.optDD == "DD2H") and (shmddcount % 4 == 2)) or ((mod.Options.optDD == "DD3H") and (shmddcount % 4 == 3)) or ((mod.Options.optDD == "DD4H") and (shmddcount % 4 == 0))	then
			specWarnChainLightning:Show(source)
			sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\kickcast.mp3") --快打斷
		end
	elseif args.spellId == 144969 then
		Ancount = Ancount + 1
		warnAnnihilate:Show()
		specWarnAnnihilate:Show()
		if MyJS("AN") then
			sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\defensive.mp3") --注意減傷
			sndWOP:Schedule(0.7, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\defensive.mp3")
		end
	elseif args:IsSpellID(144985, 145037) then
		whirlCount = whirlCount + 1
		if args.spellId == 144985 then
			warnWhirlingCorruption:Show(whirlCount)
			specWarnWhirlingCorruption:Show(whirlCount)
			Xfcount = Xfcount + 1
			if MyJS("XF") then
				sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\defensive.mp3") --注意減傷
				sndWOP:Schedule(0.7, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\defensive.mp3")
			end
		else
			warnEmpWhirlingCorruption:Show(whirlCount)
			specWarnEmpWhirlingCorruption:Show(whirlCount)
			EXfcount = EXfcount + 1
			if MyJS("EXF") then
				sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\defensive.mp3") --注意減傷
				sndWOP:Schedule(0.7, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\defensive.mp3")
			end
		end
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_hxzb.mp3")
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countthree.mp3")
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\counttwo.mp3")
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countone.mp3")
		sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_hxkd.mp3") --漩渦快躲
		sndWOP:Schedule(47, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_hxzb.mp3") --漩渦準備
		sndWOP:Schedule(48, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countthree.mp3")
		sndWOP:Schedule(49, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\counttwo.mp3")
		sndWOP:Schedule(50, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countone.mp3")
		timerWhirlingCorruption:Start()
		timerWhirlingCorruptionCD:Start(nil, whirlCount+1)
		--countdownWhirlingCorruption:Start()
		--soundWhirlingCorrpution:Play()
--[[		self:Schedule(8, function()
			if whirlCount < 3 then
				checknexttouchOfYShaarj("whirling")
			end
		end)]]
	elseif args.spellId == 147120 then
		Bombcount = Bombcount + 1
		warnBombardment:Show()
		specWarnBombardment:Show(Bombcount)
		sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\watchstep.mp3") --注意腳下
		sndWOP:Schedule(8, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countfive.mp3")
		sndWOP:Schedule(9, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countfour.mp3")
		sndWOP:Schedule(10, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countthree.mp3")
		sndWOP:Schedule(11, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\counttwo.mp3")
		sndWOP:Schedule(12, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countone.mp3")
		sndWOP:Schedule(13, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\gather.mp3")--快集合
		timerBombardment:Start()
		if Bombcount == 1 then
			timerBombardmentCD:Start()
			sndWOP:Schedule(50, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_zbhz.mp3") --準備轟炸
			sndWOP:Schedule(51, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countfour.mp3")
			sndWOP:Schedule(52, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countthree.mp3")
			sndWOP:Schedule(53, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\counttwo.mp3")
			sndWOP:Schedule(54, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countone.mp3")
		else
			timerBombardmentCD:Start(40)
			sndWOP:Schedule(35, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_zbhz.mp3")
			sndWOP:Schedule(36, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countfour.mp3")
			sndWOP:Schedule(37, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countthree.mp3")
			sndWOP:Schedule(38, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\counttwo.mp3")
			sndWOP:Schedule(39, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countone.mp3")
		end
	elseif args.spellId == 147011 then
		warnManifestRage:Show()
	elseif args.spellId == 149347 then
		if not Touchcount[args.sourceGUID] then
			Touchcount[args.sourceGUID] = 1
		else
			Touchcount[args.sourceGUID] = Touchcount[args.sourceGUID] + 1
		end
		if UnitGUID("target") == args.sourceGUID then
			specWarnTouchInterrupt:Show(Touchcount[args.sourceGUID])
		end
	end
end

function mod:SPELL_INTERRUPT(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 71983 then
		if ((mod.Options.optDD == "DD1H") and (shmddcount % 4 == 0)) or ((mod.Options.optDD == "DD2H") and (shmddcount % 4 == 1)) or ((mod.Options.optDD == "DD3H") and (shmddcount % 4 == 2)) or ((mod.Options.optDD == "DD4H") and (shmddcount % 4 == 3))	then
			sndWOP:Schedule(0.1, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\interruptsoon.mp3") --打斷準備
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(144748, 144749) then
		desecrateCount = desecrateCount + 1
		if args.spellId == 144748 then
			specWarnDesecrate:Show(desecrateCount)
		else
			specWarnEmpDesecrate:Show(desecrateCount)
		end
		if phase == 1 then
			timerDesecrateCD:Start(41, desecrateCount+1)
		elseif phase == 3 then
			timerDesecrateCD:Start(25, desecrateCount+1)
		else--Phase 2
			timerDesecrateCD:Start(nil, desecrateCount+1)
		end
		self:BossTargetScanner(71865, "DesecrateTarget", 0.02, 16)
--		checknexttouchOfYShaarj("desecrate")
	elseif args:IsSpellID(145065, 145171) then
		mindControlCount = mindControlCount + 1
		specWarnTouchOfYShaarj:Show()
		sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_xkkd.mp3") --心控快打
		if phase == 3 then
			if mindControlCount == 1 then--First one in phase is shorter than rest (well that or rest are delayed because of whirling)
				timerTouchOfYShaarjCD:Start(35, mindControlCount+1)
--				countdownTouchOfYShaarj:Start(35)
			else
				timerTouchOfYShaarjCD:Start(42, mindControlCount+1)
--				countdownTouchOfYShaarj:Start(42)
			end
		else
			timerTouchOfYShaarjCD:Start(nil, mindControlCount+1)
--			countdownTouchOfYShaarj:Start()
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 144945 then
		warnYShaarjsProtection:Show(args.destName)
		timerYShaarjsProtection:Start()
		Ancount = 0
	elseif args:IsSpellID(145065, 145171) then
		touchOfYShaarjTargets[#touchOfYShaarjTargets + 1] = args.destName
		self:Unschedule(warnTouchOfYShaarjTargets)
		self:Schedule(0.5, warnTouchOfYShaarjTargets, args.spellId)
	elseif args:IsSpellID(145071, 145175) then--Touch of Yshaarj Spread IDs?

	elseif args:IsSpellID(145183, 145195) then
		local amount = args.amount or 1
		if args.spellId == 145183 then
			warnGrippingDespair:Show(args.destName, amount)
		else
			warnEmpGrippingDespair:Show(args.destName, amount)
		end
		timerGrippingDespair:Start(args.destName)
		if amount >= 3 then
			if args:IsPlayer() then
				specWarnGrippingDespair:Show(amount)
			else
				specWarnGrippingDespairOther:Show(args.destName)
				if mod:IsTank() then
					sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\changemt.mp3") --換坦
				end
			end
		end
	elseif args.spellId == 144585 then
		shamanAlive = shamanAlive + 1
		warnFarseerWolfRider:Show()
		specWarnFarseerWolfRider:Show()
		timerFarseerWolfRiderCD:Start()
		if not mod:IsHealer() then
			sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_lqzb.mp3")
			sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_lqcx.mp3") --狼騎兵出現
			sndWOP:Schedule(45, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_lqzb.mp3") --狼騎兵準備
		end
		healcount = 0
		shmddcount = 0
		if mod.Options.optDD == "DD1" then
			sndWOP:Schedule(10, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\interruptsoon.mp3") --打斷準備
		end
		if mod.Options.optDD == "DD1H" then
			sndWOP:Schedule(2, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\interruptsoon.mp3") --打斷準備
		end
		if self.Options.SetIconOnShaman then
			scanLimiter = 0
			scanForMobs()
		end
	elseif args.spellId == 147209 then
		warnMalice:CombinedShow(0.5, args.destName)
		timerMaliceCD:DelayedStart(0.5)
		if self:AntiSpam(5, 1) then
			EYcount = EYcount + 1
		end
		if args:IsPlayer() then
			specWarnMaliceYou:Show()
			VEM.Flash:Shake(1, 0, 0)
			yellMalice:Yell()
			sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_eydn.mp3") --惡意點你
			if self.Options.LTIP then
				VEM:ShowLTSpecialWarning(GetSpellInfo(147209).."("..EYcount..")", 1, 0, 0, 1, 147209, 15, 15)
			end
		else
			sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_ey.mp3") --惡意
			if EYcount == 1 then
				sndWOP:Schedule(0.4, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countone.mp3")
			elseif EYcount == 2 then
				sndWOP:Schedule(0.4, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\counttwo.mp3")
			elseif EYcount == 3 then
				sndWOP:Schedule(0.4, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countthree.mp3")
			elseif EYcount == 4 then
				sndWOP:Schedule(0.4, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countfour.mp3")
			elseif EYcount == 5 then
				sndWOP:Schedule(0.4, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countfive.mp3")
			elseif EYcount == 6 then
				sndWOP:Schedule(0.4, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countsix.mp3")
			end
		end
	elseif args.spellId == 147235 then
		if args:IsPlayer() then
			local amount = args.amount or 1
			if amount == 1 then
				if self.Options.LTIP then
					VEM:HideLTSpecialWarning()
					VEM:ShowLTSpecialWarning(GetSpellInfo(147235).."(1)", 1, 1, 1, nil, 147235, 3, 3)
				end
			else
				if self.Options.LTIP then
					VEM:HideLTSpecialWarning()
					VEM:ShowLTSpecialWarning(GetSpellInfo(147235).."("..amount..")", 1, 0, 0, 1, 147235, 3, 3)
				end
				needwarnin = true
				sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\runout.mp3") --離開人群
			end
		end
	elseif args.spellId == 147665 then
		warnFixate:Show(args.destName)
		if args:IsPlayer() then		
			specWarnFixateYou:Show()
			timerFixate:Start()
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(145183, 145195) then
		timerGrippingDespair:Cancel(args.destName)
	elseif args.spellId == 144585 then
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\interruptsoon.mp3")
	elseif args.spellId == 147209 then
		if args:IsPlayer() then
			if self.Options.LTIP then
				VEM:HideLTSpecialWarning()
			end
		end
	elseif args.spellId == 147235 then
		if args:IsPlayer() then
			if needwarnin then
				needwarnin = false
				sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\runin.mp3") --快回人群
			end
		end
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 71984 then--Siege Engineer
		engineerDied = engineerDied + 1
		if engineerDied == 2 then
			warnFireUnstableIronStar:Cancel()
			specWarnFireUnstableIronStar:Cancel()
			timerPowerIronStar:Cancel()
--			countdownPowerIronStar:Cancel()
			sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_tqzb.mp3")
			sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_tqkd.mp3")
			sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_tqch.mp3") --鐵球摧毀
		end
	elseif cid == 71983 then--Farseer Wolf Rider
		shamanAlive = shamanAlive - 1
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, _, spellId)
	if spellId == 144821 then--Warsong. Does not show in combat log
		warnHellscreamsWarsong:Show()
		specWarnHellscreamsWarsong:Show()
		timerHellscreamsWarsongCD:Start()
		if not mod:IsDps() then
			sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_zg.mp3") --戰歌
			sndWOP:Schedule(39, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_zgzb.mp3") --戰歌準備
		end
	elseif spellId == 145235 then--Throw Axe At Heart
		timerSiegeEngineerCD:Cancel()
		sndGC:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_gczb.mp3")
		timerFarseerWolfRiderCD:Cancel()
		timerDesecrateCD:Cancel()
		timerHellscreamsWarsongCD:Cancel()
		if not mod:IsDps() then
			sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_zgzb.mp3")
		end
		timerEnterRealm:Start(25)
		if not mod:IsHealer() then
			sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_lqzb.mp3")
		end
	elseif spellId == 144866 then--Enter Realm of Y'Shaarj
		timerPowerIronStar:Cancel()
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_tqzb.mp3")
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_tqkd.mp3")
--		countdownPowerIronStar:Cancel()
		timerDesecrateCD:Cancel()
		timerTouchOfYShaarjCD:Cancel()
--		countdownTouchOfYShaarj:Cancel()
		timerWhirlingCorruptionCD:Cancel()
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_hxzb.mp3")
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countthree.mp3")
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\counttwo.mp3")
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countone.mp3")
--		countdownWhirlingCorruption:Cancel()
	elseif spellId == 144956 then--Jump To Ground (intermission ending)
		if phase == 1 then
			warnPhase2:Show()
			sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ptwo.mp3") --2階段
		else
			timerEnterRealm:Start()
		end
		phase = 2
		whirlCount = 0
		desecrateCount = 0
		mindControlCount = 0
		timerDesecrateCD:Start(10, 1)
		timerTouchOfYShaarjCD:Start(15, 1)
--		countdownTouchOfYShaarj:Start(15)
		timerWhirlingCorruptionCD:Start(30, 1)
--		countdownWhirlingCorruption:Start(30)			
		sndWOP:Schedule(26, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_hxzb.mp3") --漩渦準備
		sndWOP:Schedule(27.5, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countthree.mp3")
		sndWOP:Schedule(28.5, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\counttwo.mp3")
		sndWOP:Schedule(29.5, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countone.mp3")
--		timerEnterRealm:Start()
	--"<556.9 21:41:56> [UNIT_SPELLCAST_SUCCEEDED] Garrosh Hellscream [[boss1:Realm of Y'Shaarj::0:145647]]", -- [169886]
	elseif spellId == 145647 then--Phase 3 trigger
		phase = 3
		whirlCount = 0
		desecrateCount = 0
		mindControlCount = 0
		warnPhase3:Show()
		timerEnterRealm:Cancel()
		timerDesecrateCD:Cancel()
		timerTouchOfYShaarjCD:Cancel()
		timerWhirlingCorruptionCD:Cancel()
--		countdownTouchOfYShaarj:Cancel()
--		countdownWhirlingCorruption:Cancel()
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_hxzb.mp3")
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countthree.mp3")
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\counttwo.mp3")
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countone.mp3")
		sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\pthree.mp3") --P3
		timerDesecrateCD:Start(21, 1)
		timerTouchOfYShaarjCD:Start(30, 1)
--		countdownTouchOfYShaarj:Start(30)
		timerWhirlingCorruptionCD:Start(47.5, 1)
		sndWOP:Schedule(45, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_hxzb.mp3") --漩渦準備
--		countdownWhirlingCorruption:Start(47.5)
	elseif spellId == 146984 then--Phase 4 trigger
		phase = 4
		timerEnterRealm:Cancel()
		timerDesecrateCD:Cancel()
		timerTouchOfYShaarjCD:Cancel()
		timerWhirlingCorruptionCD:Cancel()
		warnPhase4:Show()
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_hxzb.mp3")
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countthree.mp3")
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\counttwo.mp3")
		sndWOP:Cancel("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countone.mp3")
		sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\phasechange.mp3")
		timerMaliceCD:Start(30)
		timerBombardmentCD:Start(70)
		sndWOP:Schedule(65, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_zbhz.mp3") --準備轟炸
		sndWOP:Schedule(66, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countfour.mp3")
		sndWOP:Schedule(67, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countthree.mp3")
		sndWOP:Schedule(68, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\counttwo.mp3")
		sndWOP:Schedule(69, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countone.mp3")
		self:RegisterShortTermEvents(
			"UNIT_POWER_FREQUENT boss1"--Do not want this one persisting out of combat even after a wipe, in case you go somewhere else.
		)
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, _, _, _, target)
	if msg:find("spell:144616") then
		engineerDied = 0
		warnSiegeEngineer:Show()
		specWarnSiegeEngineer:Show()
		sndGC:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_gckd.mp3") --攻城師快打
		if not firstIronStar then
			firstIronStar = true
			timerSiegeEngineerCD:Start(45)
			sndGC:Schedule(40, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_gczb.mp3") --攻城師準備
		else
			timerSiegeEngineerCD:Start()
			sndGC:Schedule(35, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_gczb.mp3")
		end
		timerPowerIronStar:Start()
--		countdownPowerIronStar:Start()
		Tqcount = Tqcount + 1
		sndWOP:Schedule(12, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_tqzb.mp3") --鐵球準備
		if mod:IsDifficulty("heroic10", "heroic25") then
			warnFireUnstableIronStar:Schedule(12)
			specWarnFireUnstableIronStar:Schedule(12)
			if MyJS("TQ") then
				sndWOP:Schedule(17.5, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\defensive.mp3")
				sndWOP:Schedule(18, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countfour.mp3")
				sndWOP:Schedule(19, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countthree.mp3")
				sndWOP:Schedule(20, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\counttwo.mp3")
				sndWOP:Schedule(21, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\countone.mp3")
			end
		else
			warnFireUnstableIronStar:Schedule(16.5)
			specWarnFireUnstableIronStar:Schedule(16.5)
			sndWOP:Schedule(16.5, "Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_tqkd.mp3") --鐵球快躲
		end
	elseif msg:find("spell:147047") then
		warnFireUnstableIronStar:Show()
		specWarnFireUnstableIronStar:Show()
		sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\ex_so_tqzb.mp3") --鐵球準備
	end
end

function mod:UNIT_POWER_FREQUENT(uId)
	local power = UnitPower(uId)
	if power == 93 and self:AntiSpam(10, 2) then
		sndNL:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\energyhigh.mp3")
	end
	if power == 95 and self:AntiSpam(10, 2) then
		sndNL:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\count95.mp3")
	end
	if power == 96 and self:AntiSpam(10, 3) then
		sndNL:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\count96.mp3")
	end
	if power == 97 and self:AntiSpam(10, 4) then
		sndNL:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\count97.mp3")
	end
	if power == 98 and self:AntiSpam(10, 5) then
		sndNL:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\count98.mp3")
	end
	if power == 99 and self:AntiSpam(10, 6) then
		sndNL:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\count99.mp3")
	end
	if power == 100 and self:AntiSpam(10, 7) then
		sndNL:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\kickcast.mp3")
	end
end