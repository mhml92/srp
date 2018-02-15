local Class = require "middleclass"
local Utils = require "Utils"

local Path = Class("Path")

function Path:initialize()
  self.path = {}
  self:reset()
end
function Path:reset()
  self.path = {{x=0,y=0}}
end

function Path:getLast()
  return self.path[#self.path]
end

function Path:hasTriple()
  return #self.path >= 3
end
function Path:getLastTriple()
    return self.path[#self.path-2], self.path[#self.path-1], self.path[#self.path]
end

-- point ( {x,y} )
function Path:append(x, y)
  table.insert(self.path,{x = x, y = y})
end

return Path
