import python

from Function f, Call c
where f.isPublic()
  and c.getKind() = "call"
  and c.getSymbol().getName() = "request"
  and f.getCalls().has(c)
  and not (f.getCalls().has(c2 | c2.getKind() = "call" and c2.getSymbol().getName() = "check_authorization"))
select f, "Missing authorization check in request handling"