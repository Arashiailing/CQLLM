import python

from Call c
where c.getCallee() = "input" or
      c.getCallee() = "sys.argv" or
      c.getCallee() = "os.getenv" or
      c.getCallee() = "request.get" or
      c.getCallee() = "eval" or
      c.getCallee() = "exec"
select c, "Potential CWE-20: Improper Input Validation"