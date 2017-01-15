--[[
This file is part of cvetool. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT. No part of cvetool, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of cvetool. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/libertine-linux/cvetool/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local cvetool = require('cvetool')
local libcurl = require('libcurl')
local zlib = require('zlib')
local ffi = require('ffi')
local exception = halimede.exception
local assert = halimede.assert
local FileHandleStream = halimede.io.FileHandleStream
local DefaultShellLanguage = halimede.io.shellScript.ShellLanguage.default()
local ZLibDecompressor = zlib.ZLibDecompressor


local function compressedUrlDownload(variantConverted, isGzipCompressed, urlPattern, stringPathOrHyphen, optionDescription)
	local url = urlPattern:gsub('%%VARIANT%%', {['%VARIANT%'] = variantConverted})
	
	local function outputFileHandleStream()
		if stringPathOrHyphen == '' or stringPathOrHyphen == '-' then
			return FileHandleStream.StandardOut
		else
			local xmlFilePath = DefaultShellLanguage:parsePath(stringPathOrHyphen, true)
			return FileHandleStream.openBinaryFileForWriting(xmlFilePath, optionDescription)
		end
	end
	local fileHandleStream = outputFileHandleStream()
	
	local libcurlEasyOptions = {
		url = url,
		noprogress = true,
		failonerror = true,
	}
	
	local zLibDecompressor
	if isGzipCompressed then
		local function callback(outputBuffer, length, finished)
			local bytes = ffi.string(outputBuffer, length)
			fileHandleStream:write(bytes)
		end
		
		zLibDecompressor = ZLibDecompressor.initialiseGzipOnlyDeflation(callback, ZLibDecompressor.OptimumDeflateBufferSize)
		libcurlEasyOptions.writefunction = function(ptr, size, nmemb, userdata)
			
			local numberOfBytesWrapped = size * nmemb
			
			local numberOfBytes = tonumber(numberOfBytesWrapped)
			
			if numberOfBytes > 0 then
				zLibDecompressor:inflate(ptr, numberOfBytes)
			end
			
			return numberOfBytesWrapped
		end
	else
		libcurlEasyOptions.writedata = fileHandleStream.fileHandle
	end
	
	local etr = libcurl.easy(libcurlEasyOptions)
	
	local result, errorMessage, errorCodeBoxedCdataEnum = etr:perform()
	local hasError = result == nil
	etr:close()
	
	if isGzipCompressed then
		zLibDecompressor:finish()
	end
	fileHandleStream:close()
	
	if result == nil then
		local errorCode = tonumber(errorCodeBoxedCdataEnum)
		exception.throw("curl failed with error code '%s' (%s)", errorCode, errorMessage)
	end
end

halimede.modulefunction(compressedUrlDownload)
