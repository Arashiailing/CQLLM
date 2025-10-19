import python
import semmle.code.python.security.UserInput

from Call site, Argument arg
where 
  site.getTarget() = "os.path.join" 
  and (arg is UserInput or arg is UserInput)
select site, "Potential Path Injection due to unvalidated user input in path construction."