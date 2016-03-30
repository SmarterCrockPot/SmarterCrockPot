local cooking = require "cooking"

local aliases=
{
	cookedsmallmeat = "smallmeat_cooked",
	cookedmonstermeat = "monstermeat_cooked",
	cookedmeat = "meat_cooked"
}

local null_ingredient = {tags={}}
function GetIngredientData(prefabname)
	local name = aliases.prefabname or prefabname

	return cooking.ingredients[name] or null_ingredient
end


function GetIngredientValues(prefablist)
	local prefabs = {}
	local tags = {}
	for k,v in pairs(prefablist) do
		local name = aliases[v] or v
		prefabs[name] = prefabs[name] and prefabs[name] + 1 or 1
		local data = GetIngredientData(name)

		if data then

			for kk, vv in pairs(data.tags) do

				tags[kk] = tags[kk] and tags[kk] + vv or vv
			end
		end
	end

	return {tags = tags, names = prefabs}
end


function GetCandidateRecipes(cooker, ingdata)
	
	local recipes = cooking.recipes["cookpot"] or {}
	local candidates = {}

	--find all potentially valid recipes
	for k,v in pairs(recipes) do
		if v.test(cooker, ingdata.names, ingdata.tags) then
			table.insert(candidates, v)
		end
	end
	table.sort( candidates, function(a,b) return (a.priority or 0) > (b.priority or 0) end )
	if #candidates > 0 then
		--find the set of highest priority recipes
		local top_candidates = {}
		local idx = 1
		local val = candidates[1].priority or 0

		for k,v in ipairs(candidates) do
			if k > 1 and (v.priority or 0) < val then
				break
			end
			table.insert(top_candidates, v)
		end
		return top_candidates
	end

	return candidates
end

--original mod functions start here
function PredictRecipes(cooker,names)		
	local ingdata = GetIngredientValues(names)
	local candidates = GetCandidateRecipes(cooker, ingdata)
	table.sort( candidates, function(a,b) return (a.weight or 1) > (b.weight or 1) end )
	return candidates
end

function PredictMany(prefab)
	local ings = {}	
    local slots = {}
    if prefab.components.container ~= nil then
        slots= prefab.components.container.slots
    else 
        slots= prefab.replica.container:GetItems()
    end
	for k,v in pairs (slots) do
		table.insert(ings, v.prefab)
	end
	local results=PredictRecipes(prefab,ings)
	return results
end			


function getWeightPercent(Recipes, index)
	local total=0
	for k,v in pairs(Recipes) do
		total = total + (v.weight or 1)
	end
	local fraction=(Recipes[index].weight or 1)/total
	local Perc=fraction
	return Perc
end

function getSpoilage(prefab)
	local spoilage_total = 0
	local spoilage_n = 0
    local slots= nil
    local spoilage = 0
    if prefab.components.container ~= nil then
        slots = prefab.components.container.slots
        spoilage = 1
        for k,v in pairs (slots) do
            if  v.components and v.components.perishable then
                spoilage_n = spoilage_n + 1
                spoilage_total = spoilage_total + v.components.perishable:GetPercent()
            end
        end	
    end
	if spoilage_total > 0 then
		spoilage = spoilage_total / spoilage_n
		spoilage = 1 - (1 - spoilage)*.5
	end
	return spoilage
end