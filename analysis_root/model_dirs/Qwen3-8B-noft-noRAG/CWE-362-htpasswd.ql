import python

from Call c, Method m
where c.getTarget() = m
  and m.getName() = "write"
  and c.getArgument(0).getType().getQualifiedName() = "builtins.file"
select c, "CWE-362: Potential cleartext storage of sensitive data via unsecured file operations."