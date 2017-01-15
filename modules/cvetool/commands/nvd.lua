--[[
This file is part of cvetool. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT. No part of cvetool, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of cvetool. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local cvetool = require('cvetool')
local toml = require('toml')
local lfs = require('syscall.lfs')
local dir = lfs.dir
local attributes = lfs.attributes
local findCves = cvetool.findCves
local FileHandleStream = halimede.io.FileHandleStream
local exception = halimede.exception
local Node = toml.Node
local folderSeparator = halimede.packageConfiguration.folderSeparator


local shortOptionName = 'i'
local longOptionName = 'input'
local optionDescription = ('-%s, --%s'):format(shortOptionName, longOptionName)

local function findAllNvdXmlFiles(options)
	local nvdDatabaseFolderPath = options['nvd-database']
	local iterator, stateOrError = dir(nvdDatabaseFolderPath)
	if iterator == nil then
		exception.throw("Could not use '--nvd-database' '%s'", nvdDatabaseFolderPath)
	end
	
	local nvdXmlFiles = {}
			
	local state = stateOrError
	local directoryEntryName
	while true do
		local directoryEntryName = iterator(state)
		if directoryEntryName == nil then
			break
		end
		
		local stringFilePath = nvdDatabaseFolderPath .. folderSeparator .. directoryEntryName
		
		if stringFilePath:endsWith('.xml') then
			local attributeMode, errorMessage = attributes(stringFilePath, 'mode')
			if attributeMode ~= nil and attributeMode == 'file' then
				nvdXmlFiles[#nvdXmlFiles + 1] = stringFilePath
			end
		end
	end
	
	return nvdXmlFiles
end

local function commandAction(options)
	local nvdXmlFiles = findAllNvdXmlFiles(options)
	if #nvdXmlFiles == 0 then
		return
	end
	
	local toml = Node.parseFromStringPathOrStandardIn(options[longOptionName], longOptionName, true)
	local name = toml:stringOrDefault('name', longOptionName, '(unspecified)')
	local cpe = toml:tableOfStrings('CPE', longOptionName)
	local cve = toml:node('CVE', longOptionName)
	local fixed = cve:tableOfStringsOrEmptyIfMissing('fixed', longOptionName)
	local irrelevant = cve:tableOfStringsOrEmptyIfMissing('irrelevant', longOptionName)
	local suppressed = cve:tableOfStringsOrEmptyIfMissing('suppressed', longOptionName)
		
	for _, nvdXmlFilePathString in ipairs(nvdXmlFiles) do
		findCves(cpe, nvdXmlFilePathString, '', function(cveId, summary)
			if fixed[cveId] then
				return
			end
			if irrelevant[cveId] then
				return
			end
			if suppressed[cveId] then
				return
			end
			hasNewCves = true
			print(name .. '\t' .. cveId .. '\t' .. summary)
		end)
		collectgarbage()
	end
	
	if hasNewCves then
		os.exit(2)
	end
end

local function parseCommandLine(cliargs)
	local command = cliargs:command('nvd', 'Checks all NVD XML database files to see if new CVEs are present; if so, exits with code 2')
	command:action(commandAction)
	command:option(optionDescription .. '=FILEPATH', '\tFILEPATH to nvd.toml; - is standard in', '-')
	command:option('-n, --nvd-database=FOLDERPATH', '\tFOLDERPATH to a folder containing NVD CVE xml files downloaded using download-nvd', '.')
	return command
end

halimede.modulefunction(parseCommandLine)
