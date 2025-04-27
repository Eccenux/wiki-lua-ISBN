-- include this library
local mw = require("mw/mw")

-- replace require to support namespace removal
local originalRequire = require
function require(moduleName)
	moduleName = moduleName:gsub("Modu[^:]+:", "")
	return originalRequire(moduleName)
end

-- Load a copy of a module
-- Note that this loads "ISBN.lua" file (a local file).
local p = require('Module:ISBN')
local json_data = '[{"label": "k: $v", "value": 33.1}, {"label": "m: $v", "value": -1}]'
local html = p.renderPie(json_data)
mw.logObject(html)