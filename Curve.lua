local Class = require "middleclass"
local Utils = require "Utils"

local Curve = Class("Curve")

function Curve:initialize()
  self:reset()
end

-- a, b, b 2d points ( {x,y} )
function Curve:append(a,b,c)
    -- calculate curvature
    local curvature = Utils.curvature(a,b,c)
    --local curvature = Utils.deltaRad(a,b,c)
    --local curvature = Utils.rad(b,c)

    -- update max for plot
    if curvature > self.max then self.max = curvature end
    if -curvature > self.max then self.max = -curvature end

    table.insert(self.data, curvature)
end

function Curve:reset()
  self.data = {}
  self.max = 0
  self.min = 0
end

return Curve
