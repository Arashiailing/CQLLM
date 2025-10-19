import python

from CallExpr c
where (c.getCallee().getName() = "chmod" and c.getArg(1).getType().getName() = "int" and c.getArg(1).getValue() = "0o777")
   or (c.getCallee().getName() = "umask" and c.getArg(0).getType().getName() = "int" and c.getArg(0).getValue() = "0")
   or (c.getCallee().getName() = "makedirs" and c.getArg(1).getType().getName() = "int" and c.getArg(1).getValue() = "0o777")
select c, "Potential CWE-276: Incorrect Default Permissions"