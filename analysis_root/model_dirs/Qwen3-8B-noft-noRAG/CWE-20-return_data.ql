import python
import semmle.code.python.security.LogInjection

from LogMessage msg, CallSite site
where msg.hasUnsanitizedInput(site)
select site, "Potential Log Injection vulnerability detected."