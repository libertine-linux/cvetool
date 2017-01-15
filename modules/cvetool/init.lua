--[[
This file is part of cvetool. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT. No part of cvetool, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of cvetool. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local createCommandLineArgumentsParser = require('cliargs.createCommandLineArgumentsParser')
local cvetool = require('cvetool')
local commands = cvetool.commands


local commandLineArgumentsParser = createCommandLineArgumentsParser(cvetool, 'Works with NIST CVE and CPE data',
	commands.download_cpe,
	commands.download_cve,
	commands.download_nvd,
	commands.download_all_nvd,
	commands.list_cpe,
	commands.list_cve,
	commands.find_cve,
	commands.nvd
)
commandLineArgumentsParser:parseCommandLineExpectingCommandAndExit()
