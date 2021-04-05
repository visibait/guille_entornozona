fx_version 'adamant'

game 'gta5'

author "guillerp#1928"

client_scripts {
    'client.lu*',
    'config.lu*'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lu*',
    'config.lu*'
}









client_script '@wg-ac/shared/ToLoad.lua'