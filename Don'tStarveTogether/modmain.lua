
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