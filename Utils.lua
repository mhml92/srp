local function length(t)
  local x, y = t.x, t.y
  return math.sqrt(x * x + y * y)
end

local function round(x)
  return math.floor(x+0.5)
end

local function sub(p1,p2)
  return {x = p1.x - p2.x, y = p1.y - p2.y}
end

local function point_equal(a,b)
  return a.x == b.x and a.y == b.y
end

local function cross(a,b)
  return a.x * b.y - a.y * b.x
end

-- points a, b, c
local function triangleArea(a, b, c)
  local area = triangleArea2(a, b, c)
  return area/2
end

-- points a, b, c
local function triangleArea2(a, b, c)
  local area = cross(sub(b,a),sub(c,b))
  return area
end


local function rad(a, b)
  if point_equal(a,b) then
    return 0
  end
  local ab  = sub(b,a)
  return math.atan2(ab.y,ab.x)

end

local function deltaRad(a, b, c)
  if point_equal(a,b) or point_equal(a, c) or point_equal(b, c) then
    return 0
  end
  return rad(b,c) - rad(a,b)
end
--[[
If the line passes through two points P1=(x1,y1) and P2=(x2,y2) then the
distance of (x0,y0) from the line is:
  {\displaystyle \operatorname {distance} (P_{1},P_{2},(x_{0},y_{0}))={\frac {|(y_{2}-y_{1})x_{0}-(x_{2}-x_{1})y_{0}+x_{2}y_{1}-y_{2}x_{1}|}{\sqrt {(y_{2}-y_{1})^{2}+(x_{2}-x_{1})^{2}}}}.} \operatorname {distance}(P_{1},P_{2},(x_{0},y_{0}))={\frac  {|(y_{2}-y_{1})x_{0}-(x_{2}-x_{1})y_{0}+x_{2}y_{1}-y_{2}x_{1}|}{{\sqrt  {(y_{2}-y_{1})^{2}+(x_{2}-x_{1})^{2}}}}}.
The denominator of this expression is the distance between P1 and P2.
The numerator is twice the area of the triangle with its vertices at the three
points, (x0,y0), P1 and P2. See: Area of a triangle § Using coordinates.
The expression is equivalent to
  {\textstyle h={\frac {2A}{b}}} {\textstyle h={\frac  {2A}{b}}},
which can be obtained by rearranging the standard formula for the area of a t
riangle:
  {\textstyle A={\frac {1}{2}}bh} {\textstyle A={\frac  {1}{2}}bh},
where b is the length of a side, and h is the perpendicular height from the
opposite vertex.

local function pointToLineSegmentDistance(point, lp1, lp2)

end
]]


-- points a, b, c
local function curvature(a, b, c)
  if point_equal(a,b) or point_equal(a, c) or point_equal(b, c) then
    return 0
  end
  local ab, ac, bc = sub(a,b), sub(a,c), sub(b,c)

  if cross(ab, ac) == 0 then
    return 0
  end

  local len1, len2, len3 = length(ab), length(ac), length(bc)
  local curvature = ( 2 * triangleArea2(a, b, c) ) / (len1 * len2 * len3)
  return curvature
end


local function getMouseAnalog()
  local width, height = love.graphics.getDimensions()
  local mx,my = love.mouse.getX(), love.mouse.getY()
  return (2*mx/width)-1, (2*my/height)-1
end

-- The x,y position of the analog Joystick
-- if the length of the vector (x,y) > 1 then the coordinates are normalized
-- if the length og the vector (x,y) < 0.1 then the vector is truncated to (0,0)
local function getRightAnalog(joystick)
  local x,y = joystick:getAxis(3), joystick:getAxis(6)
  -- normalize input vector
  local len = math.sqrt(x*x+y*y)
  if len > 1 then
    x, y = x/len, y/len
  elseif len < 0.4 then
    x, y = 0, 0
  end

  return x,y
end

return {
  length = length,
  curvature = curvature,
  deltaRad = deltaRad,
  rad = rad,
  getMouseAnalog = getMouseAnalog,
  getRightAnalog = getRightAnalog
}
