Config = Config or {}
Config.Debug = false

-- Keys
Config.Keys = {}
Config.Keys.GetUp = 73 -- Key Used To Get Out Of Bed When Using /bed Command
Config.Keys.Revive = 54 -- Key Used To Revive Or Teleport

--[[
    GENERAL SETTINGS | THESE WILL AFFECT YOUR ENTIRE SERVER SO BE SURE TO SET THESE CORRECTLY
    MaxHp : Maximum HP Allowed, set to -1 if you want to disable krabby-injury from setting this
        NOTE: Anything under 100 and you are dead
    RegenRate : 
]]
Config.MaxHp = 300
Config.RegenRate = 0.0

--[[
    HiddenRevChance : The % Chance That Using The Hidden Revive Spot Will Result In A Full Revive With All Limb Damage & Bleeds Removed
    HiddenCooldown : The time, in minutes, for how long a player must wait before using the hidden revive spot again
]]
Config.HiddenRevChance = 65
Config.HiddenCooldown = 30

--[[
    Pricing
]]
Config.InjuryBase = 1983
Config.HiddenInjuryBase = 1000

--[[
    AlertShowInfo : 
]]
Config.AlertShowInfo = 2

--[[

]]
Config.Hospital = {
    Location = { x = 312.31, y = -592.87, z = 43.28, h = 163.77},
  --  Location2 = { x= ,y= ,z= ,h= }
    ShowBlip = false,
}
Config.Hospital.Blip = { name = "RENZ FOR LIFE", color = 38, id = 153, scale = 1.0, short = false, x = Config.Hospital.Location.x, y = Config.Hospital.Location.y, z = Config.Hospital.Location.z }

--[[
    Hidden: Location of the hidden location where you can heal and no alert of GSW's will be made.
]]

Config.Hidden = {
    Location = { x = -309.03, y = -588.47, z = 247.94, h = 247.94 },
    ShowBlip = false,
}
Config.Hidden.Blip = { name = 'Hidden Medic', color = 12, id = 153, scale = 1.0, short = false, x = Config.Hidden.Location.x, y = Config.Hidden.Location.y, z = Config.Hidden.Location.z }

Config.Teleports = {
   -- { x = 338.8362121582, y = -583.79595947266, z = 74.165649414063, h = 247.53303527832, destination = 1, range = 2, text = Config.Strings.TeleportEnter },   -- from rooftop to lower
  --  { x = 298.57528686523, y = -599.33715820313, z = 43.292068481445, h = 338.03997802734, destination = 3, range = 2, text = Config.Strings.TeleportLower },  --SIDE DOOR GOIN TO LOWER ENTRANCE
  --  { x = 309.68832397461, y = -602.75939941406, z = 42.291839599609, h = 67.832542419434,destination= 1, range = 2},   --LOWER --going to rooftop
  -- { x = 338.8362121582, y = -583.79595947266, z = 74.165649414063, h = 247.53303527832, destination = 2, range = 2, text = Config.Strings.TeleportEnter },   -- from rooftop to lower	
	
	
  --  { x = 357.58139038086, y = -590.75146484375, z = 28.788959503174, h = 245.51211547852, destination = 2, range = 2, text = Config.Strings.TeleportEnter },  --lower entrance to upper

   -- { x = 298.57528686523, y = -599.33715820313, z = 43.292068481445, h = 338.03997802734, destination = 4, range = 2, text = Config.Strings.TeleportLower },-- -- from lower to rooftop

	   

}