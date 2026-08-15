-- Negative acceptance fixture: drawCanvas was removed from the callable Node protocol.
-- The analyzer must report an unknown member for this legacy access.
local node: Node<{}> = {}
local _legacy = node.drawCanvas
