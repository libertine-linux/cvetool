--[[
This file is part of cvetool. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT. No part of cvetool, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of cvetool. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local cvetool = require('cvetool')


local parseCommandLine = cvetool.createCompressedUrlDownloadCommand(
	'download-cpe',
	'downloads CPE identifiers from NVD in CPE Dictionary Metadata 0.2 format as XML',
	'https://static.nvd.nist.gov/feeds/xml/cpe/dictionary/official-cpe-dictionary_%VARIANT%.xml.gz',
	'v2.3',
	'v2.3 or v2.2',
	function(commandLineSuppliedValue)
		if commandLineSuppliedValue == 'v2.3' or commandLineSuppliedValue == 'v2.2' then
			return commandLineSuppliedValue, true
		end
		return nil
	end
)

halimede.modulefunction(parseCommandLine)
