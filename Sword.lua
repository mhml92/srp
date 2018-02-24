local Sword = Class("Sword")
local Gesture = require "Gesture"

function Sword:initialize(t)
  assert(t.max_time)
  assert(t.deadzone)
  self:setupGesture(t)
  self:setupJoystick()

  self.x, self.y = love.graphics.getDimensions()
  self.x, self.y = self.x/2, self.y/2
  self.dx, self.dy = 0,0
  self.reach = 100

  self.physics = {}
  local sp = self.physics
  sp.world = love.physics.newWorld(0, 0, false)
  sp.sword = love.physics.newBody(sp.world, self.x, self.y, "dynamic")
end

function Sword:setupJoystick()
  self.joystick = love.joystick.getJoysticks()[1]
  if self.joystick:isVibrationSupported() then
    print("Vibration support: true")
  else
    print("Vibration support: false ")
  end
end

function Sword:setupGesture(t)
  self.gesture = Gesture{max_time = t.max_time, deadzone = t.deadzone}
  self.gesture:addPatter("C", {color = {0, 0, 255}, vibration=0})
  self.gesture:addPatter("C S SW", {color={255,0,0}, vibration=1})
  self.gesture:addPatter("C S SW W NW N",{color={0,255,0}, vibration=0.5})
end

function Sword:updateGesture(dt, x, y)

  self.dx,self.dy = x,y

  self.gesture:update(dt, x, y)
  local state = self.gesture:getState()
  if state then
    love.graphics.setBackgroundColor(state.color)
    local succ = self.joystick:setVibration(state.vibration,state.vibration)
  end
end

function Sword:update(dt)
  local x, y = Utils.getRightAnalog(self.joystick)

  self:updateGesture(dt, x, y)

end

function Sword:draw()
  self.gesture:draw()
  -- "body"...
  love.graphics.setColor(127, 255, 255 )
  love.graphics.circle("fill", self.x, self.y, 25, 16)

  love.graphics.setColor(127, 127, 127)
  local width,height = 15,90
  love.graphics.rectangle("fill", -width/2 + self.x + self.reach * self.dx, -height + self.y + self.reach * self.dy, width,height)
end
return Sword
