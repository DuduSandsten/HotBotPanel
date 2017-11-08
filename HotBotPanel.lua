function HotBotPanel_OnLoad()
	if( HotBotPanel == nil ) then
		HotBotPanel = {}
	end
	
end

function HotBotPanel_OnEvent()
	
end

function HotBotPanel_OnUpdate()
	
end

function HotBotPrint(msg)
	DEFAULT_CHAT_FRAME:AddMessage(tostring(msg),0.4,1,1, 3)
end

function HotBot_HotGroup(group)
	
	if( HotBotPanel == nil ) then
		HotBotPanel = {}
	end
	
	if( HotBotPanel["HoTRank"] == nil ) then
		HotBotPanel["HoTRank"] = 4
	end 
	
	local hotrank = HotBotPanel["HoTRank"]
	
	--select hot type depending on class
	local playerClass, englishClass = UnitClass("player")
	if englishClass == "DRUID" then
		buffname="Spell_Nature_Rejuvenation"
		spellname="Rejuvenation(Rank ".. hotrank .. ")"
	elseif englishClass == "PRIEST" then
		buffname="Spell_Holy_Renew"
		spellname="Renew(Rank ".. hotrank .. ")"
	end
	
	
	if GetNumRaidMembers() > 0 then
		GetNumPartyOrRaidMembers = GetNumRaidMembers()
		PartyOrRaid = "raid"
	else
		GetNumPartyOrRaidMembers = GetNumPartyMembers()
		PartyOrRaid = "party"
	end
	
	
	for i=1,GetNumRaidMembers() do 
		local _,_,n=GetRaidRosterInfo(i)
		local unit = PartyOrRaid..i
		if n==group then 
			
			--check if unit is dead
			if not UnitIsDeadOrGhost(unit) then
				--check if buff is already active
				if HotBot_IsBuffActive(unit,buffname) == false then 
					
					TargetUnit(unit)
					
					if not HotBot_IsBuffActive("target",buffname) then
						CastSpellByName(spellname)
					end
					
					TargetLastTarget()
					
				end 
			end
		end 
	end

end

function HotBot_SelectRank()
	StaticPopupDialogs["HOTBOT_SELECTRANK"] = {
		text = "Type in the rank of the hot you want to cast when clicking. 1-11 is valid.",
	  	button1 = "Confirm",
	  	button2 = "Cancel",
		
		OnShow = function()
			getglobal(this:GetName().."EditBox"):SetFocus()
			getglobal(this:GetName().."EditBox"):SetText("4")
			getglobal(this:GetName().."EditBox"):HighlightText()
		end,
		
	  	OnAccept = function()
			local text = getglobal(this:GetParent():GetName().."EditBox"):GetText()
			if text ~= "" then
				-- Set the option
				HotBotPanel["HoTRank"] = text
			end
	  	end,
	  	timeout = 0,
	  	hasEditBox = true,
	  	whileDead = true,
	  	hideOnEscape = true,
	  	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show ("HOTBOT_SELECTRANK")
end

function HotBot_IsBuffActive(unit,buffname)
	--HotBotPrint("checking for buff "..buffname.." on unit ".. unit)
	for j=1,32 do 
		local buffTexture = tostring(UnitBuff(unit,j))
		if strfind(buffTexture,buffname) then 
			--HotBotPrint("Buff.. " .. buffname .. " found on: "..UnitName(unit))
			return true
		end 
	end
	--HotBotPrint("Buff " .. buffname .. " NOT found on: "..UnitName(unit))
	return false
end

