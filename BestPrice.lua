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
local jsonData = game:HttpGet("https://raw.githubusercontent.com/Magma122/PetsGO/refs/heads/main/shoppingList.json")
local shoppingList = game:GetService("HttpService"):JSONDecode(jsonData)

local lines = readfile("bestPrice.txt")
for _, n in shoppingList do 
    local table = { id = n.id, tn = n.tn}
    local FastJSON = require(game.ReplicatedStorage.Library.Functions.FastJSON)
    local bestPrice = BestPrice(n.ClassName, FastJSON(table))
    bestPrice = bestPrice - (bestPrice * 0.2)
    lines = lines .. i .. " " .. tostring(bestPrice) .. "\n"
end

writefile("bestPrice.txt", lines)