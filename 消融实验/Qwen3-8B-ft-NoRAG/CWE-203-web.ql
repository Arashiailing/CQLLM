import python

from Call c
where 
  c.getCallee().getName() = "print_exc" and 
  c.getModule().getName() = "traceback" and 
  c.getKind() = "call"
select c, "Potential stack trace exposure via traceback.print_exc()"