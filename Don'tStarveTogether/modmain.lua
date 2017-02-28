
local SmarterCrockPotControllerEnabled= GetModConfigData("Controller")
GLOBAL.SmarterCrockPotControllerEnabled = SmarterCrockPotControllerEnabled
GLOBAL.STRINGS.SmarterCrockPotDescriptionString = nil
modimport "modmain_segments/containerwidgetfunction.lua"
modimport "modmain_segments/containers_setup.lua"
modimport "modmain_segments/action_predict.lua"
if SmarterCrockPotControllerEnabled then
    modimport "modmain_segments/controllersupport.lua"
end


local function SmarterCookpotInit(prefab)
	
    
	prefab:AddTag("SMARTERCROCKPOT")
	if not prefab.components.predicter then
        prefab:AddComponent("predicter")
    else
        prefab:AddTag("SMARTERCROCKPOT-NOTCLIENTONLY")
    end
	if GLOBAL.TheWorld.ismastersim then
        prefab:AddTag("SMARTERCROCKPOT-NOTCLIENTONLY")
    end
    
end


AddPrefabPostInit("cookpot", SmarterCookpotInit)

AddSimPostInit(function()
    -- Smarter Crock Pot & Advanced Tooltips mods compatibility hack
    -- net_vars for mod component actions are not created when they spawn an item with TheWorld.mastersim forced to true - ModManager reads it and may return that no server mods are enabled
    if not GLOBAL.TheNet:GetIsServer() then
        local ModManager = GLOBAL.ModManager
        if ModManager.old_mastersim_GetServerModsNames == nil then
            ModManager.old_mastersim_GetServerModsNames = ModManager.GetServerModsNames
            ModManager.GetServerModsNames = function(self)
                -- replaced TheWorld.ismastersim with TheNet:GetIsServer()
                if GLOBAL.TheNet:GetIsServer() then
                    return self:GetEnabledServerModNames()
                else
                    if self.servermods == nil then
                        self.servermods = GLOBAL.TheNet:GetServerModNames()
                    end
                    return self.servermods
                end
            end
        end
    end
end)
