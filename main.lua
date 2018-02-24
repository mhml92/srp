-- globag Class
Class     = require "middleclass"
I         = require "inspect"
Utils     = require "Utils"
Gamepad   = require "Gamepad"
Windfield = require "windfield/windfield"
RagDoll   = require "RagDoll"

world = Windfield.newWorld(0, 0, true)

function love.load()

  local w,h = love.graphics.getDimensions()
  -- walls
  bottom = world:newRectangleCollider(0, h, w, 50)
  top = world:newRectangleCollider(0, -50, w, 50)

  wall_left = world:newRectangleCollider(-50, 0, 50, h)
  wall_right = world:newRectangleCollider(w, 0, 50, h)
  bottom:setType('static') -- Types can be 'static', 'dynamic' or 'kinematic'. Defaults to 'dynamic'
  top:setType('static') -- Types can be 'static', 'dynamic' or 'kinematic'. Defaults to 'dynamic'
  wall_left:setType('static')
  wall_right:setType('static')

  gamepad = Gamepad:new{joystick = love.joystick.getJoysticks()[1], deadzone = 0}
  ragDoll = RagDoll:new{
    x = 200,
    y = 400,
    gamepad = gamepad,
    bodyWidth = 100,
    bodyHeight = 50,
    upperArmWidth = 25,
    upperArmHeight = 50,
    lowerArmWidth = 25,
    lowerArmHeight = 50,
    bodyLinearDamping = 10,
    bodyAngularDamping = 20,
    handDamping = 10
  }

  ragDoll2 = RagDoll:new{
    x = 600,
    y = 400
  }

end

function love.update(dt)
    world:update(dt)
    ragDoll:update(dt)
    ragDoll2:update(dt)

end

function love.draw()
  world:draw() -- The world can be drawn for debugging purposes
  love.graphics.setColor(255,255,255)
  love.graphics.print(love.timer.getFPS(),10,10)
end
