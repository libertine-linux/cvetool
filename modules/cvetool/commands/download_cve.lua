--[[
This file is part of cvetool. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT. No part of cvetool, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of cvetool. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local cvetool = require('cvetool')
local isInteger = halimede.math.isInteger
local defaults = cvetool.defaults


local parseCommandLine = cvetool.createCompressedUrlDownloadCommand(
	'download-cve',
	'downloads CVE data from MITRE in CVRF 1.1 format as XML',
	defaults.CveUrlPattern,
	'all',
	('all, or a 4-digit year from %s inclusive'):format(defaults.CveStartYear),
	function(commandLineSuppliedValue)
		if commandLineSuppliedValue == 'all' then
			return '.xml.gz', true
		end
		
		local potentialYear = tonumber(commandLineSuppliedValue, 10)
		if potentialYear == nil then
			return nil
		end
		
		-- This year, with leniency to accept next year (as Lua doesn't do timezones)
		local protectFromSillyYears = os.date('%Y') + 1
		
		if potentialYear < defaults.CveStartYear or potentialYear > protectFromSillyYears then
			return nil
		end
		
		if isInteger(potentialYear) then
			local asString = tostring(potentialYear)
			if asString == commandLineSuppliedValue then
				return '-year-' .. tostring(potentialYear) .. '.xml', false
			end
		end
		
		return nil
	end
)

halimede.modulefunction(parseCommandLine)
