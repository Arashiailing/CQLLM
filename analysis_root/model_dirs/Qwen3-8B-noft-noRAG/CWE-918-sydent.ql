import python

/** @predicate */
from MethodCall mc
where mc.getMethodName() = "get" and mc.getFullyQualifiedName() = "requests.sessions.Session.get"
select mc, "Potential SSRF vulnerability: Unvalidated user-controlled URL in GET request"

/** @predicate */
from MethodCall mc
where mc.getMethodName() = "post" and mc.getFullyQualifiedName() = "requests.sessions.Session.post"
select mc, "Potential SSRF vulnerability: Unvalidated user-controlled URL in POST request"

/** @predicate */
from Call c
where c.getCallee().getSymbol().getName() = "urllib.request.urlopen"
select c, "Potential SSRF vulnerability: Unvalidated user-controlled URL in urllib request"