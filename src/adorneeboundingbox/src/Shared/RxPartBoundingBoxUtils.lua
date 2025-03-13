--[=[
	@class RxPartBoundingBoxUtils
]=]

local require = require(script.Parent.loader).load(script)

local RxInstanceUtils = require("RxInstanceUtils")

local RxPartBoundingBoxUtils = {}

function RxPartBoundingBoxUtils.observePartCFrame(part: BasePart)
	assert(typeof(part) == "Instance" and part:IsA("BasePart"), "Bad part")

	return RxInstanceUtils.observeProperty(part, "CFrame")
end

return RxPartBoundingBoxUtils