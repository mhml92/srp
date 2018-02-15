
local Node = require "Node"
local StateMachine = Class("StateMachine")

--------------------------------------------
-- PUBLIC
--------------------------------------------
function StateMachine:initialize()
  self.start_node = Node:new("START")
  self.current_state = nil
end

-- Add a sequence of valid state transisions
function StateMachine:addSequence(sequence)
  local sequence_key = ""
  for _,symbol in ipairs(sequence) do
    sequence_key = sequence_key .. symbol .. " "
  end
  self.current_state = self.start_node
  self:recursiveAddSequence(sequence,sequence_key)
end

-- Returns current state or nil otherwise if not a valid sequence
function StateMachine:isSequenceValid(sequence)
  self.current_state = self.start_node
  for i = 1, #sequence do
    --------------------------------------------------------------
    --if self.current_state:hasN
  end
end
--------------------------------------------
-- PRIVATE
--------------------------------------------
function StateMachine:recursiveAddSequence(sequence,sequence_key)
  head = table.remove(sequence,1)
  if not head then
    self.current_state:addSequenceKey(sequence_key)
    return
  end

  neighbor = self.current_state:getNeighbor(head)
  if neighbor then
    self.current_state = neighbor
  else
    local new_state = Node:new(head)
    self.current_state:addNeighbor(new_state)
    self.current_state = new_state
  end
  self:recursiveAddSequence(sequence,sequence_key)
end

return StateMachine
