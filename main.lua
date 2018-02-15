-- globag Class
Class = require "middleclass"
I     = require "inspect"
Utils = require "Utils"

local GestureCurve = require "GestureCurve"
local Gesture = require "Gesture"


local joystick = nil
local gestureCurve = GestureCurve:new{max_time = 0.5}
local gesture = Gesture{max_time = 0.25, deadzone = 0.4}
gesture:addPatter("C", {color = {127, 200, 4}, vibration=0})
gesture:addPatter("C S SW", {color={255,0,0}, vibration=1})
gesture:addPatter("C S SW W NW N",{color={0,255,0}, vibration=0.5})

function love.load()
  joystick = love.joystick.getJoysticks()[1]
  if joystick:isVibrationSupported() then
    print("Vibration support: true")
  else
    print("Vibration support: false ")
  end
end


function love.update(dt)
  local x, y = Utils.getRightAnalog(joystick)
  gestureCurve:update(dt, x, y)
  gesture:update(dt, x, y)
  local state = gesture:getState()
  if state then
    love.graphics.setBackgroundColor(state.color)
    local succ = joystick:setVibration(state.vibration)

  end

end


-- Draw a coloured rectangle.
function love.draw()
  gestureCurve:draw()
  gesture:draw()
  love.graphics.print(love.timer.getFPS(),10,10)
end
