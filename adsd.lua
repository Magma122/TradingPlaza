repeat task.wait() until game:IsLoaded()

queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)

if syn and syn.queue_on_teleport then
    syn.queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Magma122/TradingPlaza/refs/heads/main/adsd.lua"))()
    ]])
elseif queue_on_teleport then
    queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Magma122/TradingPlaza/refs/heads/main/adsd.lua"))()
    ]])
end

-- Load All Booths
local booths = game:GetService("Workspace"):WaitForChild("__THINGS"):WaitForChild("Booths")
local pets = 0
while #booths:GetChildren() == 0 or #booths:GetChildren() ~= pets do
    wait(1)  
    booths = game:GetService("Workspace"):WaitForChild("__THINGS"):WaitForChild("Booths")
    pets = 0
    for _, booth in pairs(booths:GetChildren()) do
        if booth:FindFirstChild("Pets"):FindFirstChild("BoothTop"):FindFirstChild("PetScroll") 
        and #booth:WaitForChild("Pets"):WaitForChild("BoothTop"):WaitForChild("PetScroll"):GetChildren() >= 2 then
            pets += 1
        end
    end
end
wait(5) -- Load ALL

-- List
local jsonData = game:HttpGet("https://raw.githubusercontent.com/Magma122/TradingPlaza/refs/heads/main/shoppingList.json")
local shoppingList = game:GetService("HttpService"):JSONDecode(jsonData)

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
function BuyItem(item, owner, cost)
    local haveDiamonds = convertToNumber(game:GetService("Players").LocalPlayer.PlayerGui.Main.Left["Diamonds Desktop"].Amount.text)
    local quantity = tonumber(item.Holder.ItemSlot:GetAttribute("Quantity"))
    local buy = {
        [1] = owner,
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
    if booth and booth:FindFirstChild("Pets") then
        local owner = booth:GetAttribute("Owner")
        for _, item in pairs(booth:WaitForChild("Pets"):WaitForChild("BoothTop"):WaitForChild("PetScroll"):GetChildren()) do
            if #item:GetChildren() > 0 then
                for _, n in shoppingList do
                    if #item:GetChildren() > 0 and item:WaitForChild("Holder"):WaitForChild("ItemSlot"):WaitForChild("Icon").Image == n.Image then
                        local itemCost = Instance.new("Message")
                        itemCost.Parent = game:GetService("CoreGui")
                        itemCost.Text = item:WaitForChild("Buy"):WaitForChild("Cost").Text .. n.id
        
                        local cost = convertToNumber(item:WaitForChild("Buy"):WaitForChild("Cost").Text)
                        local bestPrice = tonumber(n.BestPrice)

                        if cost <= bestPrice then
                            BuyItem(item, owner, cost)
                            wait(1)
                        else
                            blackList = blackList .. owner .. "\n"
                        end
                        wait(0.1)
                        itemCost:Destroy()
                    end
                end
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

    local lines = string.split(readfile("blackList.txt"), "\n")
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