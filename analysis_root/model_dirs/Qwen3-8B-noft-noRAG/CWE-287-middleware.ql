import python

/**
 * @name CWE-287: Improper Authentication
 * @description Detects improper authentication patterns in Python middleware.
 */
from method m, call c
where 
  m.name = "process_request" and
  c.getTarget() = m and
  exists(
    c.getArgument(0).getType().getName() = "HttpRequest" and
    (c.getArgument(0).getMember("headers").isPresent() or
     c.getArgument(0).getMember("cookies").isPresent() or
     c.getArgument(0).getMember("session").isPresent())
  ) and
  not exists(
    c.getArgument(0).getMember("user").isPresent() and
    c.getArgument(0).getMember("user").getType().getName() = "User"
  )
select m, "Potential CWE-287: Improper authentication detected - missing proper user validation in middleware"