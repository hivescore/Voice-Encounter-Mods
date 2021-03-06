﻿local mod	= VEM:NewMod(675, "VEM-Party-MoP", 4, 303)
local L		= mod:GetLocalizedStrings()
local sndWOP	= mod:NewSound(nil, "SoundWOP", true)

mod:SetRevision(("$Revision: 9469 $"):sub(12, -3))
mod:SetCreatureID(56589)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_SUCCESS",
	"SPELL_DAMAGE",
	"SPELL_MISSED",
	"RAID_BOSS_EMOTE"
)

local warnImpalingStrike	= mod:NewTargetAnnounce(107047, 3)
local warnPreyTime			= mod:NewTargetAnnounce(106933, 3, nil, mod:IsHealer())
local warnStrafingRun		= mod:NewSpellAnnounce("ej5660", 4)

local specWarnStafingRun	= mod:NewSpecialWarningSpell("ej5660", nil, nil, nil, true)
local specWarnStafingRunAoe	= mod:NewSpecialWarningMove(116297)
local specWarnAcidBomb		= mod:NewSpecialWarningMove(115458)

local timerImpalingStrikeCD	= mod:NewNextTimer(30, 107047)
local timerPreyTime			= mod:NewTargetTimer(5, 106933, nil, mod:IsHealer())
local timerPreyTimeCD		= mod:NewNextTimer(14.5, 106933)

function mod:OnCombatStart(delay)
--	timerImpalingStrikeCD:Start(-delay)--Bad pull, no pull timers.
--	timerPreyTimeCD:Start(-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 106933 then
		warnPreyTime:Show(args.destName)
		timerPreyTime:Start(args.destName)
		timerPreyTimeCD:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 106933 then
		timerPreyTime:Start(args.destName)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 107047 then
		warnImpalingStrike:Show(args.destName)
		timerImpalingStrikeCD:Start()
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 115458 and destGUID == UnitGUID("player") and self:AntiSpam() then
		specWarnAcidBomb:Show()
		sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\runaway.mp3")--快躲開
	elseif spellId == 116297 and destGUID == UnitGUID("player") and self:AntiSpam() then
		specWarnStafingRunAoe:Show()
		sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\runaway.mp3")--快躲開
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:RAID_BOSS_EMOTE(msg)--Needs a better trigger if possible using transcriptor.
	if msg == L.StaffingRun or msg:find(L.StaffingRun) then
		warnStrafingRun:Show()
		specWarnStafingRun:Show()
		timerImpalingStrikeCD:Start(29)
		timerPreyTimeCD:Start(32.5)
		sndWOP:Play("Interface\\AddOns\\"..VEM.Options.CountdownVoice.."\\bombsoon.mp3")--準備炸彈
	end
end
