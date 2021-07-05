# esx_pwstorage: A Password Storage system by Horse#0001
This storage can be opened by typing a registered password. Remember that anyone can open your storage by entering your password.
 
## About the Project - Preview
                                                                                         EXPIRATION DATE
                                                                                        ┌───────────── yeah
                                                                                        │   ┌───────────── month
                                                                                        │   │   ┌───────────── day
                                                                                        │   │   │
    In order to add more Storages you should use the command /addStorage name password 2021-07-20

## There are plenty options but i recommend you to keep them as it is:
    
    Config.EnableCommands             = true                        -- The commands you'll gonna enable by setting this true are: /addStorage and /renewStorage.
    Config.AuthorizedMembers          = {'admin', 'superadmin'}     -- The authorized members who will gonna be able to use the commands.
    Config.EnableSQL                  = true                        -- By setting this to true, you cancel the usage of the Config.PwStorages and you enable the SQL.
    Config.CheckForExpired            = true                        -- If you set this to true, the expiration table will be enabled.
    Config.EnableRestrictedMode       = true                        -- Restricted Mode is a safety mode to prevent multiple players access the storage at the same time.
    Config.PasswordLength             = 4                           -- The maximum password length that can be typed.

## In order to add more access points you should add coordinates here:

    Config.StorageLocations = {
      Storage = {
        Storages = {
          vector3(214.81, -806.36, 30.81),
          vector3(276.27, -342.91, 44.92)
        }
      }
    }

## And in case you set the Config.EnableSQL to false then you have to add by your self the DataBase with my examples (esx_pwstorage.sql) and set the Config.PwStorage:

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

![image](https://user-images.githubusercontent.com/42266290/123836354-48443380-d912-11eb-966d-64ffdec1901e.png)

## Upcoming

* Changes to /addStorage to work in case of non sql usage.

## Features

Resmon: ~0.01-0.03 ms.

### Dependencies:
* [ESX] ESX is needed to make this script work.
* [esx_inventoryhud] [InventoryHud](https://github.com/Trsak/esx_inventoryhud) a Fivem resource for ESX framework - Inventory HUD
* [mythic_progbar] [Mythic Progress Bar](https://github.com/HalCroves/mythic_progbar) a FiveM Client-sided Progress Bar

## Contributions

Any contribution to the project is ** highly appreciated **.

## License

You are not allowed to sell this script, or claim it's yours. Feel free to open a pull request if you find any bugs or you want to improve something.
