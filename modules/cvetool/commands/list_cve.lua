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
	local keepElements = Document.keepElementNodeIfMatchOneOfSeveralSimpleNamePaths({
		{'cvrfdoc', 'Vulnerability', 'CVE'},
		{'cvrfdoc', 'Vulnerability', 'Notes', 'Note'}
	})
	
	local xmlDocument = Document.parseFromStringPathOrStandardIn(options[longOptionName], optionDescription, Document.DefaultParsingOptions, keepElements)
	
	xmlDocument:useRootIfMatchingNamespaceUriPrefixedName('http://www.icasi.org/CVRF/schema/cvrf/1.1', 'cvrfdoc', function(root)
		root:iterateOverElementsMatchingNamespaceUriPrefixedName('http://www.icasi.org/CVRF/schema/vuln/1.1', 'Vulnerability', function(vulnerabilityElement)
			
			local cveId = vulnerabilityElement:findExactlyOneChildElementMatchingNamespaceUriPrefixedName('http://www.icasi.org/CVRF/schema/vuln/1.1', 'CVE', function(cveElement)
				return cveElement:normalizedTextValueIfOnlyOneChildAndItIsATextNode()
			end)
			
			if cveId == nil then
				return
			end
			
			local descriptions = {}
			vulnerabilityElement:findExactlyOneChildElementMatchingNamespaceUriPrefixedName('http://www.icasi.org/CVRF/schema/vuln/1.1', 'Notes', function(notesElement)
				notesElement:iterateOverElementsMatchingNamespaceUriPrefixedName('http://www.icasi.org/CVRF/schema/vuln/1.1', 'Note', function(noteElement)
					if noteElement:hasExactlyOneAttributeAndItsValueIs(NoNamespaceUri, 'Type', 'Description') then
						local description = noteElement:normalizedTextValueIfOnlyOneChildAndItIsATextNode()
						if description ~= nil then
							descriptions[#descriptions + 1] = description
						end
					end
				end)
			end)
			
			local completeDescription = table.concat(descriptions, ' ')
			
			print(cveId .. '\t' .. completeDescription)
		end)
	end)
end

local function parseCommandLine(cliargs)
	local command = cliargs:command('list-cve', 'lists all CVE identifiers (and their descriptions) from MITRE, tab-separated')
	command:action(commandAction)
	command:option(optionDescription .. '=FILEPATH', '\tFILEPATH to allitems-cvrf.xml; - is standard in', '-')
	return command
end

halimede.modulefunction(parseCommandLine)
