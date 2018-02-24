local RagDoll = Class("RagDoll")

function RagDoll:initialize(t)
  self:copyTableToSelf(t)

  self.x = self.x or love.graphics.getWidth()/2
  self.y = self.y or love.graphics.getHeight()/2
  self.bodyAngularDamping = self.bodyAngularDamping or 10
  self.bodyLinearDamping = self.bodyLinearDamping or 10
  self.bodyWidth = self.bodyWidth or 100
  self.bodyHeight = self.bodyHeight or 50
  self.upperArmWidth = self.upperArmWidth or 25
  self.upperArmHeight = self.upperArmHeight or 50
  self.lowerArmWidth = self.lowerArmWidth or 25
  self.lowerArmHeight = self.lowerArmHeight or 50
  self.handDamping = self.handDamping or 10
  -- create body
  self.body = {}
  local body = self.body
  body.width = self.bodyWidth
  body.height = self.bodyHeight
  body.x = self.x - body.width/2
  body.y = self.y - body.height/2
  body.collider = world:newRectangleCollider(body.x,body.y,body.width,body.height)
  body.collider:setAngularDamping(self.bodyAngularDamping)
  body.collider:setLinearDamping(self.bodyLinearDamping)

  self.left = {}
  self.left.upper_arm = {}
  self.left.upper_arm.width = self.upperArmWidth
  self.left.upper_arm.height = self.upperArmHeight
  self.left.upper_arm.x = body.x - self.left.upper_arm.width
  self.left.upper_arm.y = body.y - self.left.upper_arm.height
  self.left.upper_arm.collider = world:newRectangleCollider(
    self.left.upper_arm.x,
    self.left.upper_arm.y,
    self.left.upper_arm.width,
    self.left.upper_arm.height)

  joint = world:addJoint(
    'RevoluteJoint',
    body.collider,
    self.left.upper_arm.collider,
    body.x,
    body.y,
    true)

  self.left.lower_arm = {}
  self.left.lower_arm.width = self.lowerArmWidth
  self.left.lower_arm.height = self.lowerArmHeight
  self.left.lower_arm.x = self.left.upper_arm.x
  self.left.lower_arm.y = self.left.upper_arm.y - self.left.lower_arm.height
  self.left.lower_arm.collider = world:newRectangleCollider(
    self.left.lower_arm.x,
    self.left.lower_arm.y,
    self.left.lower_arm.width,
    self.left.lower_arm.height)

  joint = world:addJoint(
    'RevoluteJoint',
    self.left.upper_arm.collider,
    self.left.lower_arm.collider,
    self.left.upper_arm.x + self.left.upper_arm.width,
    self.left.upper_arm.y,
    true)

  self.right = {}
  self.right.upper_arm = {}
  self.right.upper_arm.width = self.upperArmWidth
  self.right.upper_arm.height = self.upperArmHeight
  self.right.upper_arm.x = body.x + body.width
  self.right.upper_arm.y = body.y - self.right.upper_arm.height
  self.right.upper_arm.collider = world:newRectangleCollider(
    self.right.upper_arm.x,
    self.right.upper_arm.y,
    self.right.upper_arm.width,
    self.right.upper_arm.height)

  joint = world:addJoint(
    'RevoluteJoint',
    body.collider,
    self.right.upper_arm.collider,
    body.x + body.width,
    body.y,
    true)

  self.right.lower_arm = {}
  self.right.lower_arm.width = self.lowerArmWidth
  self.right.lower_arm.height = self.lowerArmHeight
  self.right.lower_arm.x = self.right.upper_arm.x
  self.right.lower_arm.y = self.right.upper_arm.y - self.right.lower_arm.height
  self.right.lower_arm.collider = world:newRectangleCollider(self.right.lower_arm.x,self.right.lower_arm.y,self.right.lower_arm.width,self.right.lower_arm.height)
  joint = world:addJoint(
    'RevoluteJoint',
    self.right.upper_arm.collider,
    self.right.lower_arm.collider,
    self.right.upper_arm.x, --+ self.right.upper_arm.width,
    self.right.upper_arm.y, true)

  self.right.hand = {}
  self.right.hand.radius = 25/2
  self.right.hand.x = self.right.lower_arm.x + self.right.lower_arm.width/2
  self.right.hand.y = self.right.lower_arm.y - self.right.hand.radius
  self.right.hand.collider = world:newCircleCollider(self.right.hand.x,self.right.hand.y,self.right.hand.radius)
  self.right.hand.collider:setSensor(true)
  self.right.hand.collider:setLinearDamping(self.handDamping)

  joint = world:addJoint(
    'WeldJoint',
    self.right.lower_arm.collider,
    self.right.hand.collider,
    self.right.lower_arm.x + self.right.lower_arm.width/2,
    self.right.lower_arm.y, true)


  self.left.hand = {}
  self.left.hand.radius = 25/2
  self.left.hand.x = self.left.lower_arm.x + self.left.lower_arm.width/2
  self.left.hand.y = self.left.lower_arm.y - self.left.hand.radius
  self.left.hand.collider = world:newCircleCollider(self.left.hand.x,self.left.hand.y,self.left.hand.radius)
  self.left.hand.collider:setSensor(true)
  self.left.hand.collider:setLinearDamping(self.handDamping)

  joint = world:addJoint(
    'WeldJoint',
    self.left.lower_arm.collider,
    self.left.hand.collider,
    self.left.lower_arm.x + self.left.lower_arm.width/2,
    self.left.lower_arm.y,
    true)

  --self.right.upper_arm.collider:applyLinearImpulse(0, -1000)
end
function RagDoll:copyTableToSelf(t)
  for k,v in pairs(t) do
    self[k] = v
  end
end


function RagDoll:update(dt)
  local force = 100*60
  if self.gamepad then
    local rfx,rfy = self.gamepad:getRightAnalog()
    rfx,rfy = Utils.normalize_if(rfx,rfy)
    local extra_force = 1
    rfx,rfy = rfx * force, rfy * force
    if self.gamepad:isPressed("rightShoulder") then
      self.right.hand.collider:applyLinearImpulse(extra_force*rfx,extra_force*rfy)
    end
    self.right.hand.collider:applyForce(rfx,rfy)

    local lfx,lfy = self.gamepad:getLeftAnalog()
    lfx,lfy = Utils.normalize_if(lfx,lfy)
    lfx,lfy = lfx * force, lfy * force
    if self.gamepad:isPressed("leftShoulder") then
      self.left.hand.collider:applyLinearImpulse(extra_force*lfx,extra_force*lfy)
    end
    self.left.hand.collider:applyForce(lfx,lfy)
  else
    self.timer = self.timer or 0
    self.timer = self.timer + dt
    if self.timer > 1 then
      self.timer = 0
      local cx,cy = love.graphics.getDimensions()
      cx,cy = cx/2,cy/2
      local dx,dy = self.body.collider:getX(),self.body.collider:getY()
      dx,dy = Utils.normalize(cx-dx,cy-dy)

      self.left.hand.collider:applyLinearImpulse(dx*force,dy*force)
      self.right.hand.collider:applyLinearImpulse(dx*force,dy*force)
    end
  end
end

return RagDoll
