local Node = Class("Node")
--------------------------------------------
-- PUBLIC
--------------------------------------------
function Node:initialize(name)
  self.name = name -- unique name
  self.edges = {}
  self.sequence_keys = {}
end

-- If a state has a 'sequence_key' it means that this state is an END state
function Node:hasSequenceKey(sequence_key)
  return self.sequence_key[sequence_key] ~= nil
end

function Node:addSequenceKey(sequence_key)
  self.sequence_key[sequence_key] = true
end

function Node:addNeighbor(node)
  self.edges[node.name] = node
end

function Node:getNeighbor(node)
  return self.edges[node.name]
end
--------------------------------------------
-- PRIVATE
--------------------------------------------

return Node
