--[[
This file is part of cvetool. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT. No part of cvetool, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of cvetool. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local cvetool = require('cvetool')
local findCves = cvetool.findCves


local shortOptionName = 'i'
local longOptionName = 'input'
local optionDescription = ('-%s, --%s'):format(shortOptionName, longOptionName)

local function commandAction(options)
	local matchCpePrefix = options['match-cpe-prefix']
	if matchCpePrefix == '*' then
		matchCpePrefix = ''
	end
	
	local matchCpePrefixes = {matchCpePrefix}
	local nvdXmlFilePathStringOrHyphen = options[longOptionName]
	findCves(matchCpePrefixes, nvdXmlFilePathStringOrHyphen, optionDescription, function(cveId, summary)
		print(cveId .. '\t' .. summary)
	end)
end

local function parseCommandLine(cliargs)
	local command = cliargs:command('find-cve', 'Find CVEs matching CPEs (or CPE prefixes) in a NVD database')
	command:action(commandAction)
	command:option(optionDescription .. '=FILEPATH', '\tFILEPATH to nvdcve-2.0.xml; - is standard in', '-')
	command:option('-m, --match-cpe-prefix=PREFIX', "\tPREFIX of CPE to match, eg 'cpe:/a:rsync:rsync:' or '*' for all", '*')
	return command
end

halimede.modulefunction(parseCommandLine)
