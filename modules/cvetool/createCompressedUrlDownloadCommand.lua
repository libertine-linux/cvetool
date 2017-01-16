--[[
This file is part of cvetool. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT. No part of cvetool, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of cvetool. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local cvetool = require('cvetool')
local assert = halimede.assert
local exception = halimede.exception
local compressedUrlDownload = cvetool.compressedUrlDownload


local shortOptionName = 'o'
local longOptionName = 'output'
local optionDescription = ('-%s, --%s'):format(shortOptionName, longOptionName)

local function commandAction(options, variantsConversion)
	local variant = options['which']
	local urlPattern = options['url-pattern']
	local stringPathOrHyphen = options[longOptionName]
	
	local variantConverted, isGzipCompressed = variantsConversion(variant)
	if variantConverted == nil then
		exception.throw("Variant '%s' is invalid", variant)
	end
	
	compressedUrlDownload(variantConverted, isGzipCompressed, urlPattern, stringPathOrHyphen, optionDescription)
end

local function createCompressedUrlDownloadCommand(commandName, description, compressedUrlPattern, defaultVariantCommandLineName, variantsDescription, variantsConversion)
	assert.parameterTypeIsString('commandName', commandName)
	assert.parameterTypeIsString('description', description)
	assert.parameterTypeIsString('compressedUrlPattern', compressedUrlPattern)
	assert.parameterTypeIsString('defaultVariantCommandLineName', defaultVariantCommandLineName)
	assert.parameterTypeIsString('variantsDescription', variantsDescription)
	
	return function(cliargs)
		local command = cliargs:command(commandName, description)
		command:action(function(options)
			commandAction(options, variantsConversion)
		end)
		command:option("-w, --which=VARIANT", "\twhich VARIANT (" .. variantsDescription .. ") to download", defaultVariantCommandLineName)
		command:option(optionDescription .. "=FILEPATH", "\tFILEPATH to write download to; - is standard out", '-')
		command:option("-u, --url-pattern=URL", "\tURL in which %VARIANT% will be substituted", compressedUrlPattern)
		return command
	end
end

halimede.modulefunction(createCompressedUrlDownloadCommand)
