import python
import semmle.code.java.security.CodeExecution

from CallSite cs, Arg arg, Function f
where 
  (f = cs.getFunction() and 
   (f.getName() = "subprocess.run" or 
    f.getName() = "subprocess.call" or 
    f.getName() = "os.system") and 
   cs.getCallsite().getArg(0).getType().isString() and 
   cs.getCallsite().getArg(0).getValue().matches(".*userInput.*"))
select cs, "Potential CWE-88: Improper Neutralization of Argument Delimiters in a Command"