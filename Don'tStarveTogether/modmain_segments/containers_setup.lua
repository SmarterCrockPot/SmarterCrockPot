local require = GLOBAL.require
require "prefabutil"
require "class"
local containers = require "containers"
local cooking = require "cooking"


local params = {}
params.cookpot =
{
    widget =
    {
        slotpos =
        {
            --Vanilla
            GLOBAL.Vector3(0, 65+64 + 32 + 8 + 4, 0), 
            GLOBAL.Vector3(0, 65+32 + 4, 0),
            GLOBAL.Vector3(0, 65-(32 + 4), 0), 
            GLOBAL.Vector3(0, 65-(64 + 32 + 8 + 4), 0),
            
        },
        utilslotpos = 
        {
            GLOBAL.Vector3(0, 65-(72+64 + 32 + 8 + 4), 0),
            -- GLOBAL.Vector3(-55, -4*75 + 436 ,0),
        },
        animbank = "ui_cookpot_1x4",
        animbuild = "ui_cookpot_1x4",
        pos = GLOBAL.Vector3(200, 0, 0),
        side_align_tip = 100,
        buttoninfo =
        {
            text = "Cook",
            position = GLOBAL.Vector3(0, -240, 0),
        },
        buttoninfo2 =
        {
            text = "Predict!",
            position = GLOBAL.Vector3(-0, -185, 0),
        },
    },
    acceptsstacks = false,
    type = "cooker",
}
function params.cookpot.itemtestfn(container, item, slot)
    return cooking.IsCookingIngredient(item.prefab)
end

local function button_push_fn(inst,action)
    --server side
    if inst.components.container ~= nil then
        GLOBAL.BufferedAction(inst.components.container.opener, inst, action):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        if inst:HasTag("SMARTERCROCKPOT-NOTCLIENTONLY") then
            GLOBAL.SendRPCToServer(GLOBAL.RPC.DoWidgetButtonAction, action.code, inst,action.mod_name)
        else 
            --GLOBAL.SendRPCToServer(GLOBAL.RPC.DoWidgetButtonAction, action.code, inst,action.mod_name)
            inst.components.predicter:Predict()
        end
    end
end
function params.cookpot.widget.buttoninfo2.fn(inst)
    action = GLOBAL.ACTIONS.PREDICT
    if inst.components.container ~= nil then
        GLOBAL.BufferedAction(inst.components.container.opener, inst, action):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        -- if inst:HasTag("SMARTERCROCKPOT-NOTCLIENTONLY") then
            -- print("Requesting Prediction from server xxxx")
            -- GLOBAL.SendRPCToServer(GLOBAL.RPC.DoWidgetButtonAction, action.code, inst,action.mod_name)
        -- else 
            -- GLOBAL.SendRPCToServer(GLOBAL.RPC.DoWidgetButtonAction, action.code, inst,action.mod_name)
            -- print("Doing a ClientOnly Prediction xxxx")
        
        
        --EVERYONE USES CLIENT ONLY NOW
        inst.components.predicter:Predict()
        -- end
    end
end
function params.cookpot.widget.buttoninfo.fn(inst)
    action = GLOBAL.ACTIONS.COOK
    if inst.components.container ~= nil then
        GLOBAL.BufferedAction(inst.components.container.opener, inst, action):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        GLOBAL.SendRPCToServer(GLOBAL.RPC.DoWidgetButtonAction, action.code, inst,action.mod_name)
    end
end

function params.cookpot.widget.buttoninfo.validfn(inst)
    return inst.replica.container ~= nil and inst.replica.container:IsFull()
end
params.cookpot.widget.buttoninfo2.validfn = params.cookpot.widget.buttoninfo.validfn 


containers.smartercrockpot_old_widgetsetup=containers.widgetsetup

function containers.widgetsetup(container, prefab,data)
    target = prefab or container.inst.prefab
    if target == "cookpot" then
        local t = params.cookpot
        if t ~= nil then
            for k, v in pairs(t) do
                container[k] = v
            end
            container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
        end
    else
        containers.smartercrockpot_old_widgetsetup(container,prefab , data)
    end

end
