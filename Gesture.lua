local Gesture = Class("Gesture")

function Gesture:initialize(t)
  self.deadzone = t.deadzone
  self.max_time = t.max_time
  self.time = 0
  self.path = {}
  self.zone_sequence = {}
  self.current_zone = ""

  self.patterns = {}

  -- set up zones
  self.zones = {}
  local clockwise_zones = {"W", "NW", "N", "NE", "E", "SE", "S", "SW"}
  -- start of NW slice
  local rad = (math.pi / 2) - ( (3/2) * ((2*math.pi) / 8) )
  for index,symbol in ipairs(clockwise_zones) do
    self.zones[index] = {rad = rad,symbol = symbol}
    rad = rad + ( (2 * math.pi) / 8 )
  end
end

function Gesture:addPatter(pattern, data)
  self.patterns[pattern] = data
end

function Gesture:getState()
  return self.patterns[self.current_zone]
end

function Gesture:getCurrentZone(x,y)

  if math.sqrt(x * x + y * y) < 1/3 then
    return "C"
  end
  -- radian value of vector (x,y) ]0;2*pi]
  --              0,-1 => pi/2
  -- -1,0 => 2*pi,               1,0 => pi
  --              0,1 => 3/2 *pi
  local theta = math.atan2(y,x) + math.pi
  -- stupid linear search for zone
  for k,v in ipairs(self.zones) do
    if theta <= v.rad then
      return v.symbol
    end
  end
  return "W"
end

-- dt: delta time
-- x: x position of analog
-- y: y position of analog
function Gesture:update(dt, x, y)
  -- apply deadzone
  if math.sqrt(x*x + y*y) < self.deadzone then
    x, y = 0, 0
  end

  self:updateZoneSequence(dt,x,y)

  self.current_zone = ""
  for k,v in ipairs(self.zone_sequence) do
    if self.current_zone ~= "" then
      self.current_zone = self.current_zone .. " " .. v
    else
      self.current_zone = v
    end
  end
end

function Gesture:updateZoneSequence(dt, x, y)
  -- if we are not in deadzone
  if x ~= 0 or y ~= 0 then
    -- update path and find current zone
    table.insert(self.path,{x = x, y = y})
    local current_zone = self:getCurrentZone(x,y)

    -- if we are in a different zone than last frame
    if current_zone ~= self.zone_sequence[#self.zone_sequence] then
      -- update zone_sequence list
      table.insert(self.zone_sequence, current_zone)
    end
    -- reset timer
    self.time = 0
  elseif self.time > self.max_time then
    -- if we timeout then reset path and zone_sequence
    self.path = {}
    self.zone_sequence = {"C"}
    self.time = 0
  else
    self.time = self.time + dt
  end
end

function Gesture:draw()
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(self.current_zone, 310, 10)
  love.graphics.setColor(255, 255, 255)
end

return Gesture
