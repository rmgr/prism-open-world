local path = ...
local basePath = path:match("^(.*)%.") or ""

prism.worldsim = {}
prism.worldsim.WorldSim = require(basePath .. ".WorldSim")
prism.worldsim.ZoneRecord = require(basePath .. ".ZoneRecord")
prism.worldsim.ZoneFile = require(basePath .. ".ZoneFile")
prism.worldsim.SimSystem = require(basePath .. ".SimSystem")
prism.registerRegistry("simsystems", prism.worldsim.SimSystem)

prism.worldsim.NeedsComparator = require(basePath .. ".NeedsComparator")
prism.worldsim.NeedsAction = require(basePath .. ".NeedsAction")
prism.registerRegistry("needscomparators", prism.worldsim.NeedsComparator)
prism.registerRegistry("needsactions", prism.worldsim.NeedsAction)
