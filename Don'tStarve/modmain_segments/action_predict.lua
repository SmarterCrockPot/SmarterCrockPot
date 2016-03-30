local PREDICT = GLOBAL.Action(3,false,true)
PREDICT.str = "Predict"
PREDICT.id = "PREDICT"
PREDICT.fn = function(act)
	if act.target.components.predicter then
		item ,odds= act.target.components.predicter:Predict()
	end
end

AddAction(PREDICT)
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(PREDICT, "doshortaction"))

local function predicter_test_fn(inst, doer, actions,right)
                table.insert(actions, GLOBAL.ACTIONS.Predict)
end
