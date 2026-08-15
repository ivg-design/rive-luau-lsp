-- Negative acceptance fixture: the current Editor ReportedEvent is empty.
-- ReportedEventInvocation.delaySeconds remains a separately nameable legacy
-- type, but ListenerContext:asReportedEvent() does not return that type.
local context: ListenerContext = nil :: any
local reported = context:asReportedEvent()
if reported then
    local legacyDelay = reported.delaySeconds
    print(legacyDelay)
end
