local require = GLOBAL.require
require "prefabutil"

modimport "modmain_segments/action_predict.lua"
--modimport "modmain_segments/controllersupport.lua"
modimport "modmain_segments/containerwidgetfunction.lua"

GLOBAL.SmarterCrockPotLoaded = true

local SmarterCrockPotControllerEnabled= GetModConfigData("Controller")
GLOBAL.SmarterCrockPotControllerEnabled = SmarterCrockPotControllerEnabled

local function button2click(inst)
    action = GLOBAL.ACTIONS.PREDICT
    if inst.components.container ~= nil then
        GLOBAL.BufferedAction(inst.components.container.opener, inst, action):Do()
    end
end



local function SmarterCookpotInit(prefab)
	
    local slotpos = {	GLOBAL.Vector3(0,64+64+32+8+4,0), 
					GLOBAL.Vector3(0,64+32+4,0),
					GLOBAL.Vector3(0,64-(32+4),0), 
					GLOBAL.Vector3(0,64-(64+32+8+4),0)}
    utilslotpos = {}	
	table.insert(utilslotpos, GLOBAL.Vector3(0, -(7+64+32+8+4) ,0)) 
	
	prefab.components.container.widgetslotpos = slotpos
    prefab.components.container.widgetutilslotpos=utilslotpos
	
	local widgetbuttoninfo = {
	text = "Cook",
	position = GLOBAL.Vector3(0, -240, 0),
	fn = function(prefab)
		prefab.components.stewer:StartCooking()	
	end,
	
	validfn = function(prefab)
		return prefab.components.stewer:CanCook()
	end,
}
    local widgetbuttoninfo2 = {
	text = "Predict!",
	position = GLOBAL.Vector3(0, -185, 0),
	fn = function(prefab)
		button2click(prefab)
	end,
	
	validfn = function(prefab)
		return prefab.components.stewer:CanCook()
	end,
} 
    prefab.components.container.widgetbuttoninfo = widgetbuttoninfo
    prefab.components.container.widgetbuttoninfo2 = widgetbuttoninfo2
    
    if not prefab.components.predicter then
        prefab:AddComponent("predicter")
    end
    
end



AddPrefabPostInit("cookpot", SmarterCookpotInit)

