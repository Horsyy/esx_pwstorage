Config                            = {}

Config.DrawDistance               = 10.0
Config.MarkerType                 = 1
Config.MarkerSize                 = {x = 1.5, y = 1.5, z = 0.5}
Config.MarkerColor                = {r = 50, g = 50, b = 204}
Config.Locale                     = 'en'

Config.EnableCommands             = true                        -- The commands you'll gonna enable by setting this true are: /addStorage and /renewStorage.
Config.AuthorizedMembers          = {'admin', 'superadmin'}     -- The authorized members who will gonna be able to use the commands.
Config.EnableSQL                  = true                        -- By setting this to true, you cancel the usage of the Config.PwStorages and you enable the SQL.
Config.CheckForExpired            = true                        -- If you set this to true, the expiration table will be enabled.
Config.EnableRestrictedMode       = true                        -- Restricted Mode is a safety mode to prevent multiple players access the storage at the same time.
Config.PasswordLength             = 4                           -- The maximum password length that can be typed.


---------------------
--- BLIP SETTINGS ---
---------------------

Config.EnableBlips                = true
Config.BlipTransparency           = 255
Config.Sprite                     = 587
Config.BlipSize                   = 0.8
Config.BlipColor                  = 3

Config.StorageLocations = {
  Storage = {
    Storages = {
      vector3(214.81, -806.36, 30.81),
      vector3(276.27, -342.91, 44.92)
    }
  }
}

Config.PwStorages = {
  [1234] = { ['society'] = 'society_HorseStorage', 
    ['expired'] = {
      ['year']	= '2021',
      ['month']	= '07',
      ['day']	= '04'
    }
  },
  [4321] = { ['society'] = 'society_ShokaStorage', 
    ['expired'] = {
      ['year']	= '2021',
      ['month']	= '07',
      ['day']	= '02'
    }
  },
  [1314] = { ['society'] = 'society_OpsoStorage', 
    ['expired'] = {
      ['year']	= '2021',
      ['month']	= '07',
      ['day']	= '10'
    }
  },
}
