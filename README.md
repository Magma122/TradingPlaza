# PetsGO
local args = {
    [1] = "Consumable",
    [2] = "{\"id\":\"Corrupted Huge Bait\",\"tn\":1}",
    [4] = false
}

game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("TradingTerminal_Search"):InvokeServer(unpack(args))
