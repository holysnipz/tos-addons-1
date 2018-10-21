--[[ v1.0.2 ]]--

if _G["ADDONS"] == nil then _G["ADDONS"] = {}; end

_G["ADDONS"]["COLOREDITEMNAMES"] = {};
COLOREDITEMNAMES = _G["ADDONS"]["COLOREDITEMNAMES"];

function COLOREDITEMNAMES_ON_INIT(addon, frame)
	COLOREDITEMNAMES.addon = addon;
	COLOREDITEMNAMES.frame = frame;
	COLOREDITEMNAMES.init();
end

function COLOREDITEMNAMES.getItemRarityColor(itemObj)

	local itemProp = geItemTable.GetProp(itemObj.ClassID);
	local grade = itemObj.ItemGrade;

	if (itemObj.ItemType == "Recipe") then
		-- Thank you Mie for these next four lines. Great suggestion! :)
		local recipeGrade = string.match(itemObj.Icon, "misc(%d)");
		if recipeGrade ~= nil then
			grade = tonumber(recipeGrade) - 1;
		end
	end

	if (itemProp.setInfo ~= nil) then return "00FF00"; -- set piece
	elseif (grade == 0) then return "FFBF33"; -- premium
    elseif (grade == 1) then return "FFFFFF"; -- common
    elseif (grade == 2) then return "108CFF"; -- rare
    elseif (grade == 3) then return "9F30FF"; -- epic
    elseif (grade == 4) then return "FF4F00"; -- Good old Red/Orange-ish Legendary that degraded to unique
    elseif (grade == 5) then return "FFFF00"; -- All new Bright-Yellow legendary.
    end

	return "E1E1E1"; -- no grade (non-equipment items)

end

function COLOREDITEMNAMES.getColoredName(itemClass, ...)

	local nameString = _G["GET_FULL_NAME_OLD"](itemClass, ...);
	local itemColor = COLOREDITEMNAMES.getItemRarityColor(itemClass);

	return string.format("{#%s}{ol}%s{/}{/}", itemColor, nameString);

end

function COLOREDITEMNAMES.linkItem(invItem)
	-- Same as the original, with `GET_FULL_NAME` kept to use `GET_FULL_NAME_OLD`.
	-- Shortend a few lines, but mostly still IMC's code. Blame them if it breaks. :P

	local chatFrame = GET_CHATFRAME();
	local editCtrl = GET_CHILD(chatFrame, "mainchat", "ui::CEditControl");

	local itemObj = GetIES(invItem:GetObject());
	local itemClassID = itemObj.ClassID;

	local itemName = _G["GET_FULL_NAME_OLD"](itemObj);

	local imgName = GET_ITEM_ICON_IMAGE(itemObj);
	local imgTag = string.format("{img %s %d %d}", imgName, editCtrl:GetHeight(), editCtrl:GetHeight());

	local properties = "";

	if (itemObj.ClassName == "Scroll_SkillItem") then
		local skillClass = GetClassByType("Skill", itemObj.SkillType)
		itemName = itemName .. "(" .. skillClass.Name ..")";
		properties = GetSkillItemProperiesString(itemObj);
	else
		properties = GetModifiedPropertiesString(itemObj);
	end

	if (properties == "") then properties = 'nullval'; end

	local linkString = string.format("{a SLI %s %d}{#0000FF}%s%s{/}{/}{/}", properties, itemClassID, imgTag, itemName);
	SET_LINK_TEXT(linkString);

end

function COLOREDITEMNAMES.setHooks(newFunction, oldFunction)
	-- This is the SET_HOOK function directly from Excrulon's utility.lua

	local storedFunction = oldFunction .. "_OLD";

	if _G[storedFunction] == nil then
		_G[storedFunction] = _G[oldFunction];
		_G[oldFunction] = newFunction;
	else
		_G[oldFunction] = newFunction;
	end

end

function COLOREDITEMNAMES.init()

	if (COLOREDITEMNAMES.isLoaded ~= true) then

		COLOREDITEMNAMES.setHooks(COLOREDITEMNAMES.getColoredName, "GET_FULL_NAME");
		COLOREDITEMNAMES.setHooks(COLOREDITEMNAMES.linkItem, "LINK_ITEM_TEXT");
		--ui.SysMsg("[DEVLOADER] Colored Item Names loaded!");
		COLOREDITEMNAMES.isLoaded = true;

	end

end
