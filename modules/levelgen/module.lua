local path = ...
local basePath = path:match("^(.*)%.") or ""

prism.levelgen = {}
prism.levelgen.util = {}
prism.levelgen.util.RoomManager = require(basePath .. ".util.room_manager")
prism.levelgen.util.BspGenerator = require(basePath .. ".util.bsp_generator")
--- @module "modules.levelgen.generator"
prism.levelgen.Generator = require(basePath .. ".generator")
--- @module "modules.levelgen.decorator"
prism.levelgen.Decorator = require(basePath .. ".decorator")

prism.registerRegistry("generators", prism.levelgen.Generator)
prism.registerRegistry("decorators", prism.levelgen.Decorator)
