fx_version 'cerulean'
game 'gta5'

author 'Randolio'
description 'Simple flight test'

shared_scripts {
	'@ox_lib/init.lua',
	'shared.lua'
}

client_scripts {
	'cl_flight.lua'
}

server_scripts {
	'sv_flight.lua'
}

lua54 'yes'
