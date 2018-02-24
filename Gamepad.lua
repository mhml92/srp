local Gamepad = Class("Gamepad")

function Gamepad:initialize(t)
  assert(t.joystick)
  print("Joystick info: ------------------------------------------------------")
  print("Is gamepad:",t.joystick:isGamepad())
  print("Joystick name: ",t.joystick:getName())
  print("Is vibration supported: ",t.joystick:isVibrationSupported())

  self.joystick = t.joystick
  self.deadzone = t.deadzone or 0

  self.isActive = {}
  for i = 1, self.joystick:getButtonCount() do
    self.isActive[i] = self.joystick:isDown(i)
  end
end

function Gamepad:toButtonCode(button)
  if     button == "leftShoulder" then
    return 5
  elseif button == "rightShoulder" then
    return 6
  elseif button == "leftHat" then
    return 11
  elseif button == "rightHat" then
    return 12
  end
end

function Gamepad:isDown(button)
  buttonCode = self:toButtonCode(button)
  Utils.testJoystickButtons(self.joystick)
  return self.joystick:isDown(buttonCode)
end

function Gamepad:isPressed(button)

  Utils.testJoystickButtons(self.joystick)

  buttonCode = self:toButtonCode(button)
  if self.joystick:isDown(buttonCode) and not self.isActive[buttonCode] then
    self.isActive[buttonCode] = true
    return true
  elseif not self.joystick:isDown(buttonCode) then
    self.isActive[buttonCode] = false
  end
end


-- The x,y position of the analog Joystick
-- if the length of the vector (x,y) > 1 then the coordinates are normalized
-- if the length og the vector (x,y) < 0.1 then the vector is truncated to (0,0)
function Gamepad:getRightAnalog()
  local x,y = self.joystick:getAxis(3), self.joystick:getAxis(6)
  -- normalize input vector
  local len = math.sqrt(x*x+y*y)
  if len > 1 then
    x, y = x/len, y/len
  elseif len < self.deadzone then
    x, y = 0, 0
  end
  return x,y
end

function Gamepad:getLeftAnalog(joystick)
  local x,y = self.joystick:getAxis(1), self.joystick:getAxis(2)
  -- normalize input vector
  local len = math.sqrt(x*x+y*y)
  if len > 1 then
    x, y = x/len, y/len
  elseif len < self.deadzone then
    x, y = 0, 0
  end
  return x,y
end

return Gamepad
