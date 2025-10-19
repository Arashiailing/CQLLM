import python

from Call c, Argument a
where (c.getSelector().getName() = "open" and a.getArgumentIndex() = 0) or 
      (c.getSelector().getName() = "os.system" and a.getArgumentIndex() = 0) or 
      (c.getSelector().getName() = "subprocess.call" and a.getArgumentIndex() = 0) or 
      (c.getSelector().getName() = "subprocess.run" and a.getArgumentIndex() = 0)
      and a.isUserInput()
select c, "Potential CWE-59: Improper link resolution in file operation"