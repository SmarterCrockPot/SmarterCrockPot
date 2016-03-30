local require = GLOBAL.require
local Inv = require("widgets/inventorybar")

GLOBAL.smartercrockpot_prediction_slot = nil
Inv.old_GetInventoryLists = Inv.GetInventoryLists
Inv.old_OnControl = Inv.OnControl
Inv.old_UpdateCursorText = Inv.UpdateCursorText
function Inv:GetInventoryLists(same_container_only) --This is to allow controller to nav into util_slot
    lists = self:old_GetInventoryLists(same_container_only)
    if GLOBAL.smartercrockpot_prediction_slot ~= nil then
        list_of_util_slot = {GLOBAL.smartercrockpot_prediction_slot}
        table.insert(lists,list_of_util_slot)
    end 
    return lists
end

function Inv:OnControl(control, down) 
    if Inv._base.OnControl(self, control, down) then
            return true
    elseif not self.open or down then
        return
    end
    
    self:old_OnControl(control, down)
    
    if self.active_slot then 
        if self.active_slot and self.active_slot.is_prediction_slot then
            containers = GLOBAL.ThePlayer.HUD.controls.containers
            for k,v in pairs(containers) do
                        if k.components and k.components.predicter then
                            if k.replica.container ~= nil and k.replica.container:IsFull() then
                                k.components.predicter:Predict()
                                if GLOBAL.smartercrockpot_prediction_slot ~= nil then
                                    -- self:SelectSlot(GLOBAL.smartercrockpot_prediction_slot)
                                end
                                return
                            end
                        end
            end
        end
    end
end

function Inv:UpdateCursorText()
    if not (self.active_slot and self.active_slot.is_prediction_slot) then
        self:old_UpdateCursorText()
        return
    end
    --truth is, I already know what to display. 
    --Just need to initialize so many parameters
    if GLOBAL.STRINGS.SmarterCrockPotDescriptionString then
        local item = GLOBAL.STRINGS.SmarterCrockPotDescriptionString
        --find the first linebreak
        local i,j = string.find(item,"\n")
        local title = string.sub(item,0,i)
        local description = string.sub(item,i+1)
        self.actionstringtitle:SetString(title)
        self:SetTooltipColour(GLOBAL.unpack(GLOBAL.NORMAL_TEXT_COLOUR))

        --body must have text in order to show!
        self.actionstringbody:SetString(description)
        
        local was_shown = self.actionstring.shown
        local w0, h0 = self.actionstringtitle:GetRegionSize()
        local w1, h1 = self.actionstringbody:GetRegionSize()
        
        local wmax = math.max(w0, w1)

        local dest_pos = self.active_slot:GetWorldPosition()
        local xscale, yscale, zscale = self.root:GetScale():Get()
        if self.active_slot.side_align_tip then
            -- in-game containers, chests, fridge
            self.actionstringtitle:SetPosition(wmax/2, h0/2)
            self.actionstringbody:SetPosition(wmax/2, -h1/2)

            dest_pos.x = dest_pos.x + self.active_slot.side_align_tip * xscale
        else
            if self.active_slot.top_align_tip then
                    -- main inventory
                    self.actionstringtitle:SetPosition(0, h0/2 + h1)
                    self.actionstringbody:SetPosition(0, h1/2)

                    dest_pos.y = dest_pos.y + (self.active_slot.top_align_tip + TIP_YFUDGE) * yscale
            else
                    -- old default as fallback ?
                    self.actionstringtitle:SetPosition(0, h0/2 + h1)
                    self.actionstringbody:SetPosition(0, h1/2)

                    dest_pos.y = dest_pos.y + (W/2 + TIP_YFUDGE) * yscale
            end
        end

        if dest_pos:DistSq(self.actionstring:GetPosition()) > 1 then
            if was_shown then
                self.actionstring:MoveTo(self.actionstring:GetPosition(), dest_pos, .1)
            else
                self.actionstring:SetPosition(dest_pos)
                self.actionstring:Show()
            end
            self.actionstring:Show()
        end  
    end
end