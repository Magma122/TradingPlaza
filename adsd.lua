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

-- List

local list = {
    ["{\"id\":\"Fishing Bait\",\"tn\":5}"] = "rbxassetid://112224184101102",
    ["{\"id\":\"Crystal Key Lower Half\"}"] = "rbxassetid://15000810798",
    ["{\"id\":\"Crystal Key Upper Half\"}"] = "rbxassetid://15000810636"
}

-- Convert To Number
function convertToNumber(text)
    local multipliers = {b= 1000000000, m = 1000000, k = 1000}
    local multiplier = multipliers[text:sub(-1)] or 1

    if multiplier > 1 then
        text = text:sub(1, -2)
    end
    return tonumber(text) * multiplier
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
    print(#booths:GetChildren(), pets)
end

local function BestPrice()
    local module = require(game:GetService("ReplicatedStorage").Library.Client.RAPCmds)


    local args
    args = {
        Class = { Name = "Misc" },
        StackKey = function(self)
            return "{\"id\":\"Crystal Key Lower Half\"}"
        end,
        AbstractGetRAP = function()
            -- Реализуйте ожидаемую логику
            return nil -- Пример значения
        end
    }
    print(module.Get(args))
end

-- Buy All item
local blackList = readfile("blackList.txt")
for _, booth in pairs(booths:GetChildren()) do
    if booth and booth:FindFirstChild("Pets") then
        for _, item in pairs(booth.Pets.BoothTop.PetScroll:GetChildren()) do
            if (#item:GetChildren() > 0) and (item.Holder.ItemSlot.Icon.Image == "rbxassetid://112224184101102")then
                local cost = convertToNumber(item.Buy.Cost.Text)

                local itemCost = Instance.new("Message")
                itemCost.Parent = game:GetService("CoreGui")
                itemCost.Text = item.Buy.Cost.Text
    
                local screenGui = Instance.new("ScreenGui")
                screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
                local icon = item.Holder.ItemSlot.Icon:Clone()
                icon.Position = UDim2.new(0.5, -100, 0.5, -50)
                icon.Parent = screenGui

                -- B
                local bestPrice = BestPrice()


                if cost <= bestPrice then
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
                else
                    blackList = blackList .. booth:GetAttribute("Owner") .. "\n"
                end
                wait(0.5)
                itemCost:Destroy()
                icon:Destroy()
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