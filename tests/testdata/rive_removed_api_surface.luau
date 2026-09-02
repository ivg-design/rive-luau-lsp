--!strict
-- Negative acceptance fixture for retired, stale, unsupported, and host-only
-- names at the runtime-v0.1.344 target.
local node: Node<{}> = {}
local _legacy = node.drawCanvas

local animation: Animation = nil :: any
animation:play()

local listener: ListenerContext = nil :: any
listener:isGamepad()
listener:asGamepad()

local reported: ReportedEvent = nil :: any
local _legacyDelay = reported.delaySeconds

local blob: Blob = nil :: any
local _unsupportedString = blob:asString()

local list: PropertyList = nil :: any
local _unsupportedCount = list.count
local _unsupportedItem = list:item(1)

-- Host asset records are not Luau globals or source-level module names.
local _hostScriptAsset: ScriptAsset? = nil
local _hostScriptModuleAsset: ScriptModuleAsset? = nil
