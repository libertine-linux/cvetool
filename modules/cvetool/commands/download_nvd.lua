--[[
This file is part of cvetool. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT. No part of cvetool, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of cvetool. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local cvetool = require('cvetool')
local isInteger = halimede.math.isInteger
local defaults = cvetool.defaults


local parseCommandLine = cvetool.createCompressedUrlDownloadCommand(
	'download-nvd',
	'downloads v2.0 National Vulnerability Database',
	defaults.NvdUrlPattern,
	'Modified',
	('Modified, Recent, or a 4-digit year from %s inclusive'):format(defaults.NvdStartYear),
	function(commandLineSuppliedValue)
		if commandLineSuppliedValue == 'Modified' or commandLineSuppliedValue == 'Recent' then
			return commandLineSuppliedValue, true
		end
		
		local potentialYear = tonumber(commandLineSuppliedValue, 10)
		if potentialYear == nil then
			return nil
		end
		
		-- This year, with leniency to accept next year (as Lua doesn't do timezones)
		local protectFromSillyYears = os.date('%Y') + 1
		
		if potentialYear < defaults.NvdStartYear or potentialYear > protectFromSillyYears then
			return nil
		end
		
		if isInteger(potentialYear) then
			local asString = tostring(potentialYear)
			if asString == commandLineSuppliedValue then
				return asString, true
			end
		end
		
		return nil
	end
)

halimede.modulefunction(parseCommandLine)
