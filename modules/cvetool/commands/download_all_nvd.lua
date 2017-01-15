--[[
This file is part of cvetool. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT. No part of cvetool, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of cvetool. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local cvetool = require('cvetool')
local lfs = require('syscall.lfs')
local findCves = cvetool.findCves
local defaults = cvetool.defaults
local compressedUrlDownload = cvetool.compressedUrlDownload
local mkdir = lfs.mkdir


local shortOptionName = 'o'
local longOptionName = 'output'
local optionDescription = ('-%s, --%s'):format(shortOptionName, longOptionName)

local isGzipCompressed = false
local urlPattern = defaults.NvdUrlPattern
local function commandAction(options)
	
	local DefaultShellLanguage = halimede.io.shellScript.ShellLanguage.default()
	local outputFolderPath = DefaultShellLanguage:parsePath(options[longOptionName], false)
	outputFolderPath:mkdirs(function(parentPathStringToCreateAssumingAllParentsAreExtant)
		mkdir(parentPathStringToCreateAssumingAllParentsAreExtant)
	end)
	
	local toYear = tonumber(os.date('%Y'))
	local year = defaults.NvdStartYear
	while year <= toYear do
		
		local variantConverted = tostring(year)
		local xmlFilePath = outputFolderPath:appendFile('nvdcve-' .. variantConverted, 'xml')
		local stringPathOrHyphen = xmlFilePath:toString(false)
		compressedUrlDownload(variantConverted, isGzipCompressed, urlPattern, stringPathOrHyphen, optionDescription .. ' for year ' .. variantConverted)
		
		year = year + 1
	end
	
end

local function parseCommandLine(cliargs)
	local command = cliargs:command('download-all-nvd', 'Download all NVD database files to date')
	command:action(commandAction)
	command:option(optionDescription .. '=FOLDERPATH', '\tFOLDERPATH to download to', './nvdcve')
	command:option("-u, --url-pattern=URL", "\tURL in which %VARIANT% will be substituted", urlPattern)
	return command
end

halimede.modulefunction(parseCommandLine)
