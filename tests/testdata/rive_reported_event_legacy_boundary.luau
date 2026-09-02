-- Negative acceptance fixture: the current Editor ReportedEvent is empty.
-- Runtime-v0.1.316 ReportedEventInvocation.delaySeconds remains separately
-- nameable, but ListenerContext:asReportedEvent() returns the current Editor
-- ReportedEvent type rather than that runtime dispatch wrapper.
local context: ListenerContext = nil :: any
local reported = context:asReportedEvent()
if reported then
    local legacyDelay = reported.delaySeconds
    print(legacyDelay)
end
