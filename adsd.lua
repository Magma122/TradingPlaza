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

local bestPrice = 3000

function convertToNumber(text)
    local multipliers = {b= 1000000000, m = 1000000, k = 1000}
    local multiplier = multipliers[text:sub(-1)] or 1

    if multiplier > 1 then
        text = text:sub(1, -2)
    end

    return tonumber(text) * multiplier
end

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
   
local blackList = ""
for _, booth in pairs(booths:GetChildren()) do
    if booth and booth:FindFirstChild("Pets") then
        for _, item in pairs(booth.Pets.BoothTop.PetScroll:GetChildren()) do
            if (#item:GetChildren() > 0) and (item.Holder.ItemSlot.Icon.Image == "rbxassetid://112224184101102")then
                local cost = convertToNumber(item.Buy.Cost.Text)
                --print(cost)
                local itemCost = Instance.new("Message")
                itemCost.Parent = game:GetService("CoreGui")
                itemCost.Text = item.Buy.Cost.Text
    
                local screenGui = Instance.new("ScreenGui")
                screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
                local icon = item.Holder.ItemSlot.Icon:Clone()
                icon.Position = UDim2.new(0.5, -100, 0.5, -50)
                icon.Parent = screenGui
                
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

local textik = readfile("blackList.txt")

writefile("blackList.txt", textik .. blackList)

local args = {
    [1] = "Consumable",
    [2] = "{\"id\":\"Fishing Bait\",\"tn\":5}",
    [4] = false
}

while true do
    local result = game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("TradingTerminal_Search"):InvokeServer(unpack(args))
    

    if result and result.place_id and result.job_id then
        pcall(function()
            return game:GetService("TeleportService"):TeleportToPlaceInstance(result["place_id"], result["job_id"], game.Players.LocalPlayer)
        end)
        wait(1)
    end
end