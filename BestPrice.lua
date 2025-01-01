-- Best Price
function BestPrice(ClassName, StackKey)
    local module = require(game:GetService("ReplicatedStorage").Library.Client.RAPCmds)
    local args
    args = {
        Class = { Name = ClassName },
        StackKey = function()
            return StackKey
        end,
        AbstractGetRAP = function()
            return nil
        end
    }
    local Rap = module.Get(args)
    if Rap ~= nil then
        return Rap
    else
        wait(0.1)
        return BestPrice(ClassName, StackKey)
    end
    
end

-- List
local shoppingList = {
    ["{\"id\":\"Fishing Bait\",\"tn\":5}"] = {
        Image = "rbxassetid://112224184101102",
        ClassName = "Consumable"
    },    
    ["{\"id\":\"Crystal Key Lower Half\"}"] = {
        Image = "rbxassetid://15000810798",
        ClassName = "Misc"
    },
    ["{\"id\":\"Crystal Key Upper Half\"}"] = {
        Image = "rbxassetid://15000810636",
        ClassName = "Misc"
    },
}

for i, n in shoppingList do
    local bestPrice = BestPrice(n.ClassName, i)
    bestPrice = bestPrice - (bestPrice * 0.2)
end