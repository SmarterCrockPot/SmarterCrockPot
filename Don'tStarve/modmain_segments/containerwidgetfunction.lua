local require = GLOBAL.require
require "class"
local InvSlot = require "widgets/invslot"
local UtilSlot = require "widgets/utilslot"--mod
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local ItemTile = require "widgets/itemtile"
local ContainerWidget = require("widgets/containerwidget")
GLOBAL.smartercrockpot_prediction_slot = nil

ContainerWidget.old_container_open = ContainerWidget.Open
ContainerWidget.old_container_close = ContainerWidget.Close
ContainerWidget.old_on_item_get = ContainerWidget.OnItemGet
ContainerWidget.old_on_item_lose = ContainerWidget.OnItemLose


function ContainerWidget:Open(container, doer)

    self:old_container_open(container, doer)
    if container.components.container.widgetbuttoninfo2 ~= nil then
        self.bganim.inst.UITransform:SetScale(1,1.4,1)
    end
	if container.components.container.widgetbuttoninfo2 ~= nil and not GLOBAL.TheInput:ControllerAttached() then
		self.button2 = self:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex"))
	    self.button2:SetPosition(container.components.container.widgetbuttoninfo2.position)
	    self.button2:SetText(container.components.container.widgetbuttoninfo2.text)
	    self.button2:SetOnClick( function() container.components.container.widgetbuttoninfo2.fn(container, doer) end )
	    self.button2:SetFont(GLOBAL.BUTTONFONT)
	    self.button2:SetTextSize(35)
	    self.button2.text:SetVAlign(GLOBAL.ANCHOR_MIDDLE)
	    self.button2.text:SetColour(0,0,0,1)
	    
		if container.components.container.widgetbuttoninfo2.validfn then
			if container.components.container.widgetbuttoninfo2.validfn(container, doer) then
				self.button2:Enable()
			else
				self.button2:Disable()
			end
		end
	end

    self.onpredictionfn = function(inst, data) self:OnPrediction(data) end
    self.inst:ListenForEvent("prediction", self.onpredictionfn, container)
    
    self.utilslots={}
    GLOBAL.smartercrockpot_prediction_slot = nil 
    -- print("GLOBAL.TheInput:ControllerAttached()=",GLOBAL.TheInput:ControllerAttached())
    -- print("GLOBAL.SmarterCrockPotControllerEnabled=",GLOBAL.SmarterCrockPotControllerEnabled)
    -- if GLOBAL.TheInput:ControllerAttached() and  GLOBAL.SmarterCrockPotControllerEnabled then
        -- self:CreateUtilSlot()
    -- end
    
end    

function ContainerWidget:OnItemGet(data)
    self:old_on_item_get(data)
    -- if GLOBAL.TheInput:ControllerAttached() and GLOBAL.SmarterCrockPotControllerEnabled then
        -- self:CreateUtilSlot()
    -- end
	if self.button2 and self.container and self.container.components.container.widgetbuttoninfo2 and self.container.components.container.widgetbuttoninfo2.validfn then
		if self.container.components.container.widgetbuttoninfo2.validfn(self.container) then
			self.button2:Enable()
		else
			self.button2:Disable()
		end
	end
end



function ContainerWidget:OnPrediction(data)--mod
	if self.owner and self.container and self.container.components and self.container.components.container then
        --delete the current util slot to avoid stacking
		if self.utilslots and self.utilslots[1] then
			self:RemoveChild(self.utilslots[1])
		end
		self.utilslots={}
        
        if (not data.item) or (not data.odds) then
            return
        end
        
		--create slot
		local slot = GLOBAL.smartercrockpot_prediction_slot or self:CreateUtilSlot()
        local tile = ItemTile(data.item)
        tile:SetPercent(data.odds)
        local dsc_str = data.str
        tile.GetDescriptionString =function() return dsc_str end
        tile:Show()
		--place item in slot
		slot:SetTile(tile)
		--add slot to the crock pot for users to see
		self:AddChild(slot)
		--remember slots for later deleting or more sophisticated unimplemented use
		table.insert(self.utilslots,slot)
	end
		
end


function ContainerWidget:CreateUtilSlot()
    
    if self.container and self.container.components and self.container.components.container and self.container.components.container:IsFull() then   
        if self.container.components.container.widgetbuttoninfo2 then
            local slot = UtilSlot(1,"images/hud.xml", "inv_slot.tex", self.owner, self.container.components.container)
            --add slot to the crock pot for users to see
            self:AddChild(slot)
            --remember slots for later deleting or more sophisticated unimplemented use
            table.insert(self.utilslots,slot)
            --give location

            slot:SetPosition(self.container.components.container.widgetutilslotpos[1])
            GLOBAL.smartercrockpot_prediction_slot = slot
            
            if not self.container.components.container.side_widget and self.container.components.container.side_align_tip then
                slot.side_align_tip = self.container.components.container.side_align_tip - self.container.components.container.widgetutilslotpos[1].x
            end
            
            return slot
        end
    end
end

function ContainerWidget:OnUpdate(dt)
	if self.isopen and self.owner and self.container then
		
		if not (self.container.components.inventoryitem and self.container.components.inventoryitem:IsHeldBy(self.owner)) then
			local distsq = self.owner:GetDistanceSqToInst(self.container)
			if distsq > 3*3 then
				self:Close()
			end
		end
	end
	
	--return self.should_close_widget ~= true
end

function ContainerWidget:OnItemLose(data)--mod
	self:old_on_item_lose(data)
    self:KillUtilSlot()
	if self.button2 and self.container and self.container.components.container.widgetbuttoninfo2 and self.container.components.container.widgetbuttoninfo2.validfn then
		if self.container.components.container.widgetbuttoninfo2.validfn(self.container) then
			self.button2:Enable()
		else
			self.button2:Disable()
		end
	end
	
end


function ContainerWidget:KillUtilSlot()
    if self.utilslots then
        for k,v in pairs(self.utilslots) do
            self:RemoveChild(v)
            v:Kill()
        end
    end
    self.utilslots={}
    GLOBAL.smartercrockpot_prediction_slot = nil 
end

function ContainerWidget:Close()
    
    self:KillUtilSlot()
    if self.button2 then
			self.button2:Kill()
			self.button2 = nil
		end
    --end mod
    self:old_container_close(container, doer)
    --self:Hide()

end
