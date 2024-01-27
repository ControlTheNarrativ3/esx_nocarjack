--[[ FX Information ]]--
fx_version   'cerulean'
lua54        'yes'
game        'gta5'


--[[ Resource Information ]]--
name         'NoCarJack'
description 'ESX NoCarJack - by 0xNOP and updated by ControlTheNarrativ3 @ FiveM'
repository   'https://github.com/ControlTheNarrativ3/esx_nocarjack'
version '1.0.0'

shared_script '@es_extended/imports.lua'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/nocarjack_sv.lua'
}

client_scripts {
	'client/nocarjack_cl.lua',
	'cfg/nocarjack.lua'
}