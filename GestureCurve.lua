local Path = require "Path"
local Curve = require "Curve"
local GestureCurve = Class("GestureCurve")


function GestureCurve:initialize(t)
  self.max_time = t.max_time
  self.time = 0
  self.curve = Curve:new()
  self.path = Path:new()
  self.pattern_path = {}
  self:reset()

  -- debug draw data
  local dap = {}
  dap.pos = {x = 0, y = 0}
  dap.size = 300
  self.debug_analog_pos = dap

  local dcg = {}
  dcg.pos = {x = 0, y = dap.pos.y + dap.size}
  dcg.width = dap.size * 2
  dcg.height = dap.size
  self.debug_curve_graph = dcg
end

function GestureCurve:reset()
  self.time = 0
  self.path:reset()
  self.curve:reset()
  self.pattern_path = nil
  self.pathHasUpdate = false
end

-- dt: delta time
-- x: x position of analog [-1;1]
-- y: y position of analog [-1;1]
function GestureCurve:update(dt, x, y)
  self:updatePath(dt,x,y)
  self:updateCurve()

  self:comparePathToPattern()
end

function GestureCurve:comparePathToPattern()
  local result = 0
  for k,v in ipairs(self.path.path) do
    
  end
end
function GestureCurve:pathHasBeenUpdated()
  return self.pathHasUpdate
end

function GestureCurve:updateCurve()
  if self.path:hasTriple() and self:pathHasBeenUpdated() then
    -- get points
    local a, b, c = self.path:getLastTriple()
    self.curve:append(a,b,c)
  end

end

function GestureCurve:updatePath(dt, x, y)
  if love.keyboard.isDown("c") then
    self.pattern_path = {}
    for k,v in ipairs(self.path.path) do
      table.insert(self.pattern_path,v)
    end
  end
  -- if there is no input AND timer has run out
  self.pathHasUpdate = false
  if x == 0 and y == 0 then
    local t = self.path:getLast()
    if t.x ~= 0 and t.y ~= 0 then
      self.path:append(x,y)
      self.pathHasUpdate = true
    end
    self.time = self.time + dt
    if  love.keyboard.isDown("space") then
      self:reset()
    end
  else
    if #self.path.path > 1 then
      if self:isAboveThreshold(x,y) then
        self.path:append(x,y)
        self.pathHasUpdate = true
      end
    else
      self.path:append(x,y)
      self.pathHasUpdate = true
    end
    self.time = 0
  end

end

function GestureCurve:isAboveThreshold(x,y)
  local p1 = self.path:getLast()
  local dx,dy = x-p1.x,y-p1.y
  local len = Utils.length({x=dx,y=dy})
  return len > 0.1
end

function GestureCurve:draw()
  self:debug_draw()
end
--------------------------------------------
-- PRIVATE
--------------------------------------------
function GestureCurve:reset()
  self.time = 0
  self.pathHasUpdate = false
  self.curve:reset()
  self.path:reset()
end

function GestureCurve:debug_draw()
  self:debug_draw_analog_position()
  self:debug_draw_curve_graph()
end

function GestureCurve:debug_draw_curve_graph()
  local d = self.debug_curve_graph
  local tx, ty = d.pos.x, d.pos.y
  local lx_offset = 30
  local lx_start, ly_start = d.pos.x + lx_offset, d.pos.y
  local l_width = d.width - lx_offset
  local font_height = 14
  self:debug_draw_curve_graph_background(tx,ty,lx_offset,lx_start,ly_start,l_width,lx_offset,font_height)
  love.graphics.print(self.curve.max, lx_start, ly_start)
  local points = {}
  for k,v in ipairs(self.curve.data) do
      local xp = ((k/#self.curve.data) * (l_width - lx_offset)) + tx + lx_offset
      local yp = ((v)/(2 * self.curve.max) * -d.height) + ty + d.height/2
      table.insert(points,{x=xp,y=yp})
  end

  for i = 2, #points do
    local p1, p2 = points[i-1], points[i]

    love.graphics.setColor(0, 0, 0, 100)
    love.graphics.line(p1.x, p1.y, p2.x, p2.y)
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.circle("fill", p1.x, p1.y, 2, 4)
  end
end

function GestureCurve:debug_draw_analog_position()
  local d = self.debug_analog_pos

  -- draw background
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle("fill", d.pos.x, d.pos.y, d.size, d.size)
  love.graphics.setColor(200, 200, 200)
  love.graphics.circle("fill", d.pos.x + d.size/2, d.pos.y + d.size/2, d.size/2, 32)
  love.graphics.setColor(100, 100, 100)
  -- draw deadzone as 0.1 of d.size
  love.graphics.circle("fill", d.pos.x + d.size/2, d.pos.y + d.size/2, (d.size*0.4)/2, 16)

  -- draw pattern path
  love.graphics.setLineWidth(3)
  for i = 2, #self.pattern_path do
    local p1, p2 = self.pattern_path[i-1], self.pattern_path[i]
    love.graphics.setColor(0, 255, 0,127)
    love.graphics.line(
      (p1.x * d.size/2) + d.size/2 + d.pos.x,
      (p1.y * d.size/2) + d.size/2 + d.pos.y,
      (p2.x * d.size/2) + d.size/2 + d.pos.x,
      (p2.y * d.size/2) + d.size/2 + d.pos.y
    )
    love.graphics.setColor(0, 255, 0,255)
    love.graphics.circle(
      "fill",
      (p2.x * d.size/2) + d.size/2 + d.pos.x,
      (p2.y * d.size/2) + d.size/2 + d.pos.y,
       d.size/100, 4)
  end
  love.graphics.setLineWidth(1)
  -- draw line
  for i = 2, #self.path.path do
    local p1, p2 = self.path.path[i-1], self.path.path[i]
    love.graphics.setColor(255, 0, 0,127)
    love.graphics.line(
      (p1.x * d.size/2) + d.size/2 + d.pos.x,
      (p1.y * d.size/2) + d.size/2 + d.pos.y,
      (p2.x * d.size/2) + d.size/2 + d.pos.x,
      (p2.y * d.size/2) + d.size/2 + d.pos.y
    )
    love.graphics.setColor(255, 0, 0,255)
    love.graphics.circle(
      "fill",
      (p2.x * d.size/2) + d.size/2 + d.pos.x,
      (p2.y * d.size/2) + d.size/2 + d.pos.y,
       d.size/100, 4)
  end

  -- draw curser
  local width, height = love.graphics.getDimensions()
  local mx,my = love.mouse.getX(), love.mouse.getY()
  mx,my =  (2*mx/width)-1, (2*my/height)-1
  love.graphics.setColor(0, 0, 0)
  love.graphics.circle("fill", mx * d.size/2 + d.size/2 + d.pos.x, my * d.size/2 + d.size/2 + d.pos.y, d.size/50, 8)
end

function GestureCurve:debug_draw_curve_graph_background(tx,ty,lx_offset,lx_start,ly_start,l_width,lx_offset,font_height)
  local d = self.debug_curve_graph

  -- draw background
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle("fill", d.pos.x, d.pos.y, d.width, d.height)

  love.graphics.setColor(0,0,0,127)

  love.graphics.line(
    lx_start, ly_start,
    lx_start, ly_start + d.height
  )

  love.graphics.line(lx_start, ly_start, lx_start + l_width, ly_start)
  love.graphics.setColor(0,0,0)
  love.graphics.print("max", tx, ty)

  love.graphics.setColor(0,0,0,127)
  love.graphics.line(lx_start, ly_start + d.height/2, lx_start + l_width, ly_start + d.height/2)
  love.graphics.setColor(0,0,0)
  love.graphics.print("  0", tx, ty + d.height/2 - font_height/2)

  love.graphics.setColor(0,0,0,127)
  love.graphics.line(lx_start, ly_start + d.height, lx_start + l_width, ly_start + d.height
  )
  love.graphics.setColor(0,0,0)
  love.graphics.print("min", tx, ty + d.height- font_height)
end

return GestureCurve
