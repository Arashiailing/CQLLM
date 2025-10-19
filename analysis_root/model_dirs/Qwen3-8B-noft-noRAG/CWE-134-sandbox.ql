import python

/**
 * Query to detect CWE-134: Use of Externally-Controlled Format String.
 */
from Call call, StringLiteral sl, Argument arg
where 
  call.getMethod().getName() in ["print", "format"] and
  arg.getArgumentNumber() = 0 and
  arg.getValue() = sl and
  sl.getSourceLocation().getFile().getShortName()!= "main.py" and
  exists(ExternalSource src where src.getLocation() = sl.getLocation())
select call, "Potential CWE-134: Use of externally-controlled format string"