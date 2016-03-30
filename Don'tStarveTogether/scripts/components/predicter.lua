local ItemTile = require "widgets/itemtile"
require "cooking_replica"

local Predicter= Class(function(self, inst)
    self.inst = inst
	
    self.prediction_odds = 1
    self.prediction_item = nil
    self.prediction_item_str = nil
    
    self.prediction_data = {item = self.prediction_item, odds = self.prediction_odds, str = self.prediction_item_str}
    self.net_prediction_data = net_entity(self.inst.GUID,"prediction_data","prediction_data_changed")
       
    if not TheWorld.ismastersim then
        self.prediction_data_changed_fn = function(inst, data) self:On_prediction_data_changed(data) end   
        self.inst:ListenForEvent("prediction_odds_changed", self.prediction_data_changed_fn )
    end
    
end)

function Predicter:On_prediction_data_changed(data)
    local prefab = self.inst
    self.prediction_item = self.net_prediction_item:value()
    if self.prediction_odds then
        prefab:PushEvent("prediction",{item = self.prediction_item,odds = self.prediction_odds,str= self.prediction_item_changed_str})
    end
    
end

function Predicter:removeEatLMBfromStr(str)
    --find the first linebreak
    local i,j = string.find(str,"\n")
    --find the second linebreak
    local i2,j2 = string.find(str,"\n",i+1)
    --find the second line and replace it with a linebreak
    return string.gsub(str,string.sub(str,i,i2),"\n",1)
end


function Predicter:SpawnPrefabAsServerAndRemoveFromWorld(name)
    --This is Super Hackish and if you crash because of this, please do not hate me
    local loot = nil
    local str = nil
    if TheWorld.ismastersim then --and some condition defined in mod configuration maybe
        loot=SpawnPrefab(name)
        local atlas = loot.replica.inventoryitem:GetAtlas()
        local image = loot.replica.inventoryitem:GetImage()
        local tile = ItemTile(loot)
        str = tile:GetDescriptionString()
        loot:Remove()
        loot.replica.inventoryitem.GetAtlas = function() return atlas end
        loot.replica.inventoryitem.GetImage = function() return image end
        tile:Kill()
    else
        TheWorld.ismastersim = true
        
        loot=SpawnPrefab(name)
        local atlas = loot.replica.inventoryitem:GetAtlas()
        local image = loot.replica.inventoryitem:GetImage()
        local tile = ItemTile(loot)
        str = tile:GetDescriptionString()
        tile:Kill()
        --This Line is all because of Advanced tooltip's bad code
        TheWorld.ismastersim = true
        loot:Remove()
        loot.replica.inventoryitem.GetAtlas = function() return atlas end
        loot.replica.inventoryitem.GetImage = function() return image end
        
         TheWorld.ismastersim = false
    end
    if loot.replica.inventoryitem then
        loot.replica.inventoryitem.DeserializeUsage = function() end
    end
    str =self:removeEatLMBfromStr(str)
    return loot,str
    
end



local function SetSpoilageOfLoot(loot,spoilage)
    if loot and loot.components.perishable then
        if spoilage > 0 then
            loot.components.perishable:SetPercent(spoilage)
        else
            loot:RemoveComponent("perishable")
        end
    end	
end

function Predicter:PromoteDisplayIndex(PredictedProducts)
    if self.DisplayIndexForRecipes and PredictedProducts[self.DisplayIndexForRecipes+1] then
		self.DisplayIndexForRecipes = self.DisplayIndexForRecipes + 1
	else 
		self.DisplayIndexForRecipes = 1
	end
end


function Predicter:Predict()
    local prefab = self.inst
	self.PredictedProducts=PredictMany(prefab)
	self:PromoteDisplayIndex(self.PredictedProducts)
    
    local loot,description_str = self:SpawnPrefabAsServerAndRemoveFromWorld(self.PredictedProducts[self.DisplayIndexForRecipes].name)
    local spoilage = getSpoilage(prefab)
    SetSpoilageOfLoot(loot,spoilage)
    
    local chance = getWeightPercent(self.PredictedProducts,self.DisplayIndexForRecipes)
    self.prediction_odds = chance
	
    description_str = description_str.."\n" .. "Chance" .. " "  .. (chance * 100) .."%"
    
    local data = {item = loot,odds = chance,str=description_str}
    
    
    STRINGS.SmarterCrockPotDescriptionString = description_str

    prefab:PushEvent("prediction", data)
    
    self.prediction_item = loot
    self.prediction_odds = chance
    self.prediction_item_str = description_str
    
    self.prediction_data = data
    self.net_prediction_data:set(self.prediction_data)
    
    
    return loot,chance
end




return Predicter