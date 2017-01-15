--[[
This file is part of cvetool. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT. No part of cvetool, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of cvetool. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local xmldom = require('xmldom')
local Document = xmldom.Document
local NoNamespaceUri = xmldom.NoNamespaceUri


local shortOptionName = 'i'
local longOptionName = 'input'
local optionDescription = ('-%s, --%s'):format(shortOptionName, longOptionName)

local function commandAction(options)
	local keepElements = Document.keepElementNodeIfMatchInSimpleNamesPath(
		'cpe-list',
			'cpe-item',
				'title'
	)
	local cpeDictionaryXmlDocument = Document.parseFromStringPathOrStandardIn(options[longOptionName], optionDescription, Document.DefaultParsingOptions, keepElements)
	
	cpeDictionaryXmlDocument:useRootIfMatchingNamespaceUriPrefixedName('http://cpe.mitre.org/dictionary/2.0', 'cpe-list', function(root)
		root:iterateOverElementsMatchingNamespaceUriPrefixedName('http://cpe.mitre.org/dictionary/2.0', 'cpe-item', function(cpeItemElement)
			local cpeName = cpeItemElement:findExactlyOneAttributeAndReturnItsValueOrNil(NoNamespaceUri, 'name')
			if cpeName == nil then
				-- TODO: Log to standard error
				return
			end
			
			local deprecated = cpeItemElement:findExactlyOneAttributeAndReturnItsValueOrNil(NoNamespaceUri, 'deprecated')
			if deprecated == nil then
				deprecated = false
			elseif deprecated == 'true' then
				deprecated = true
			else
				-- TODO: Log to standard error
				return
			end
			
			cpeItemElement:iterateOverElementsMatchingNamespaceUriPrefixedName('http://cpe.mitre.org/dictionary/2.0', 'title', function(titleElement)
				
				local text = titleElement:normalizedTextValueIfOnlyOneChildAndItIsATextNode()
				if text ~= nil then
					print(cpeName .. '\t' .. text .. '\t' .. tostring(deprecated))
				end
			end)
		end)
	end)
	
end

local function parseCommandLine(cliargs)
	local command = cliargs:command('list-cpe', 'lists all CPE identifiers (and their descriptions) from MITRE, tab-separated')
	command:action(commandAction)
	command:option(optionDescription .. '=FILEPATH', '\tFILEPATH to official-cpe-dictionary_v2.3.xml; - is standard in', '-')
	return command
end

halimede.modulefunction(parseCommandLine)
