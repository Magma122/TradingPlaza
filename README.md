# PetsGO

local args = {
    [1] = "dooolooooo",
    [2] = "adsadsadsa",
    [3] = "Egg",
    [4] = "f81159df539949c881c2916f6771f756",
    [5] = 1
}

game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Mailbox: Send"):InvokeServer(unpack(args))

game:GetService("ReplicatedStorage").Library.Items