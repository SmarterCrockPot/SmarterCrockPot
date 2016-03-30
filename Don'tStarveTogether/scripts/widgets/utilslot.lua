--mod widget.
-- Identical in interface to InvSlot
-- only the click\trade methods are blank.
--inspect is untouched

local ItemSlot = require "widgets/itemslot"


local UtilSlot = Class(ItemSlot, function(self, num, atlas, bgim, owner, container)
    ItemSlot._ctor(self, atlas, bgim, owner)
    self.owner = owner
    self.container = container
    self.num = num
    self.is_prediction_slot = true
end)

function UtilSlot:GetSlotNum()
    if self.tile and self.tile.item then
        return self.tile.item.components.inventoryitem:GetSlotNum()
    end
end

function UtilSlot:OnControl(control, down)
    if UtilSlot._base.OnControl(self, control, down) then return true end
    return true
end 


function UtilSlot:Click(stack_mod)    
end


--moves items between open containers
function UtilSlot:TradeItem(stack_mod)
end

return UtilSlot
