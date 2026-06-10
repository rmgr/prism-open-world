local path = ...
local basePath = path:match("^(.*)%.") or ""

prism.worldsim = {}
prism.worldsim.WorldSim = require(basePath .. ".WorldSim")
prism.worldsim.ZoneRecord = require(basePath .. ".ZoneRecord")
prism.worldsim.SimSystem = require(basePath .. ".SimSystem")
prism.registerRegistry("simsystems", prism.worldsim.SimSystem)
