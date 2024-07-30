fx_version 'cerulean'
games { 'rdr3', 'gta5' }
lua54 'yes'

shared_scripts{
	'@es_extended/imports.lua',
	'@ox_lib/init.lua'
}

client_scripts {
	-- Config Files
	'strings.lua',
	'config.lua',
	'definitions.lua',
	'functional_config.lua',
	'client/scaleform.lua',
	
	'client/shared/defines.lua',
	'client/shared/functions.lua',
	'client/shared/threads.lua',

	-- Wound Files
	--'client/wound/defines.lua',
	'client/wound/functions.lua',
	'client/wound/events.lua',
	'client/wound/threads.lua',

	-- Hospital Files
	'client/hospital/shared/events.lua',
	'client/hospital/hospital/functions.lua',
	'client/hospital/hospital/teleports.lua',
	'client/hospital/hospital/events.lua',
	'client/hospital/hospital/threads.lua',
	'client/hospital/hidden/events.lua',
	'client/hospital/hidden/threads.lua',
	
	'client/items.lua',
}

server_scripts {
	'strings.lua',
	'config.lua',
	'server/billing.lua',
	'server/wound.lua',

	'server/hospital/shared/defines.lua',
	'server/hospital/shared/functions.lua',
	'server/hospital/hospital/events.lua',
	'server/hospital/hidden/events.lua',
	'server/hospital/hidden/threads.lua',
}

exports {
	'IsInjuredOrBleeding',
	'DoLimbAlert',
	'DoBleedAlert',
	'ResetAll'
}

server_exports {
    'GetCharsInjuries',
}
