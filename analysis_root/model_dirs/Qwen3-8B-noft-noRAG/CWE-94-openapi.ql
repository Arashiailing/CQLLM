import python
from Call c, Argument arg
where 
  c.getTarget().getDecl().getName() = "loads" and 
  (c.getFunction().getModule().getName() = "pickle" or 
   (c.getFunction().getModule().getName() = "yaml" and 
    c.getFunction().getName() = "load"))
  and arg.getArgumentPosition() = 0
select c, "Unsafe deserialization detected via potential use of pickle.loads or yaml.load without validation."