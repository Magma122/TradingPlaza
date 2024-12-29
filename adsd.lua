if not game:IsLoaded() then
    local notLoaded = Instance.new("Message")
    notLoaded.Parent = game:GetService("CoreGui")
    notLoaded.Text = "Wait"
    game.Loaded:Wait()
    notLoaded:Destroy()
end

queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)

if syn and syn.queue_on_teleport then
    syn.queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Magma122/PetsGO/refs/heads/main/adsd.lua"))()
    ]])
elseif queue_on_teleport then
    queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Magma122/PetsGO/refs/heads/main/adsd.lua"))()
    ]])
end

-- Load All Booths
local booths = game:GetService("Workspace"):WaitForChild("__THINGS"):WaitForChild("Booths")
local pets = 0
while #booths:GetChildren() == 0 or #booths:GetChildren() ~= pets do
    wait(0.1)  
    booths = game:GetService("Workspace"):WaitForChild("__THINGS"):WaitForChild("Booths")
    pets = 0
    for _, booth in pairs(booths:GetChildren()) do
        if booth:FindFirstChild("Pets"):FindFirstChild("BoothTop"):FindFirstChild("PetScroll") 
        and #booth:WaitForChild("Pets"):WaitForChild("BoothTop"):WaitForChild("PetScroll"):GetChildren() >= 2 then
            pets += 1
            print(#booth:WaitForChild("Pets"):WaitForChild("BoothTop"):WaitForChild("PetScroll"):GetChildren())
        end
    end 
    -- print(#booths:GetChildren(), pets)
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
    return Rap
end

-- Convert To Number
function convertToNumber(text)
    local multipliers = {b= 1000000000, m = 1000000, k = 1000}
    local multiplier = multipliers[text:sub(-1)] or 1

    if multiplier > 1 then
        text = text:sub(1, -2)
    end
    return tonumber(text) * multiplier
end

-- Buy item
function BuyItem(item, booth, cost)
    local haveDiamonds = convertToNumber(game:GetService("Players").LocalPlayer.PlayerGui.Main.Left["Diamonds Desktop"].Amount.text)
    local quantity = tonumber(item.Holder.ItemSlot:GetAttribute("Quantity"))
    local buy = {
        [1] = booth:GetAttribute("Owner"),
        [2] = {
            [item.Name] = 1
        }
    }
    if haveDiamonds / (quantity*cost) >= quantity then
        buy[2][item.Name] = quantity
    else
        buy[2][item.Name] = math.floor(haveDiamonds / (quantity*cost))
    end
    pcall(game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Booths_RequestPurchase"):InvokeServer(unpack(buy)))
end

-- Buy All item
local blackList = readfile("blackList.txt")
for _, booth in pairs(booths:GetChildren()) do
    for _, item in pairs(booth.Pets.BoothTop.PetScroll:GetChildren()) do
        for i, n in shoppingList do
            if item.Holder.ItemSlot.Icon.Image == n.Image then
                local itemCost = Instance.new("Message")
                itemCost.Parent = game:GetService("CoreGui")
                itemCost.Text = item.Buy.Cost.Text

                local cost = convertToNumber(item.Buy.Cost.Text)
                local bestPrice = BestPrice(n.ClassName, i)
                if cost <= bestPrice then
                    BuyItem(item, booth, cost)
                else
                    blackList = blackList .. booth:GetAttribute("Owner") .. "\n"
                end
                wait(0.5)
                itemCost:Destroy()
            end
        end
    end         
end    

writefile("blackList.txt", blackList)

local args = { 
    [1] = "Consumable",
    [2] = "{\"id\":\"Fishing Bait\",\"tn\":5}",
    [4] = false
}

while true do
    local result = game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("TradingTerminal_Search"):InvokeServer(unpack(args))

    local textik = readfile("blackList.txt")
    local lines = string.split(textik, "\n")
    local blackList = false
    pcall(function()
        for i, line in ipairs(lines) do
            if result["user_id"] ~= nil and result["user_id"] == line then
                blackList =  true
                break
            end
        end
        if not blackList then
            return game:GetService("TeleportService"):TeleportToPlaceInstance(result["place_id"], result["job_id"], game.Players.LocalPlayer)
        end    
    end)
    wait(1)
end