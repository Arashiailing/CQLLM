import python

/**
 * Detects potential path traversal vulnerabilities by identifying untrusted data used in path expressions.
 */
from Method m, Call c, Argument a
where 
  m.getName() = "open" and 
  c.getTarget() = m and 
  a.getIndex() = 0 and 
  exists(Argument arg, StringLiteral sl |
    c.getArguments() contains arg and 
    arg.getIndex() = 1 and 
    arg.getValue().getKind() = "String" and 
    sl.getValue() like "%../%" or 
    sl.getValue() like "%..\\%"
  ) and 
  not (c.getQualifier().getName() = "tempfile" or 
       c.getQualifier().getName() = "pathlib" or 
       c.getQualifier().getName() = "os")
select c, "Potential path traversal vulnerability detected: untrusted data used in file path"