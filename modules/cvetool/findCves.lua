--[[
This file is part of cvetool. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT. No part of cvetool, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of cvetool. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local xmldom = require('xmldom')
local Document = xmldom.Document
local NoNamespaceUri = xmldom.NoNamespaceUri


local function findCves(matchCpePrefixes, nvdXmlFilePathStringOrHyphen, optionDescription, callback)
	
	local keepElements = Document.keepElementNodeIfMatchOneOfSeveralSimpleNamePaths({
		{'nvd', 'entry', 'vulnerable-software-list', 'product'},
		{'nvd', 'entry', 'summary'},
	})
	
	local document = Document.parseFromStringPathOrStandardIn(nvdXmlFilePathStringOrHyphen, optionDescription, Document.DefaultParsingOptions, keepElements)
	
	document:useRootIfMatchingNamespaceUriPrefixedName('http://scap.nist.gov/schema/feed/vulnerability/2.0', 'nvd', function(root)
		root:iterateOverElementsMatchingNamespaceUriPrefixedName('http://scap.nist.gov/schema/feed/vulnerability/2.0', 'entry', function(entry)
			
			local matchedCpeIds = entry:findExactlyOneChildElementMatchingNamespaceUriPrefixedName('http://scap.nist.gov/schema/vulnerability/0.4', 'vulnerable-software-list', function(vulnerable_software_list)
				
				local matchedCpeIds = {}
				vulnerable_software_list:iterateOverElementsMatchingNamespaceUriPrefixedName('http://scap.nist.gov/schema/vulnerability/0.4', 'product', function(product)
					local cpeId = product:normalizedTextValueIfOnlyOneChildAndItIsATextNode()
					if cpeId == nil then
						-- TODO: Log to standard error
						return
					end
					
					for _, matchCpePrefix in ipairs(matchCpePrefixes) do
						if cpeId:startsWith(matchCpePrefix) then
							matchedCpeIds[#matchedCpeIds + 1] = cpeId
							break
						end
					end
				end)
				
				return matchedCpeIds
			end)
			
			if matchedCpeIds == nil then
				return
			end
			
			if #matchedCpeIds == 0 then
				return
			end
			
			local cveId = entry:findExactlyOneAttributeAndReturnItsValueOrNil(NoNamespaceUri, 'id')
			if cveId == nil then
				-- TODO: Log to standard error
				return
			end
			
			-- summary
			local summary = entry:findExactlyOneChildElementMatchingNamespaceUriPrefixedName('http://scap.nist.gov/schema/vulnerability/0.4', 'summary', function(summary)
				return summary:normalizedTextValueIfOnlyOneChildAndItIsATextNode()
			end)
			if summary == nil then
				-- TODO: Log to standard error
				return
			end
			
			callback(cveId, summary)
		end)
	end)
end

halimede.modulefunction(findCves)
