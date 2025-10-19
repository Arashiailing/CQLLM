@name PathInjectionCheck
@description Detects potential path injection vulnerabilities by identifying unsafe handling of user inputs in file operations.
@id py/path_injection

import python
import semmle.code.cpp.dataflow.DataFlow

from MethodCall mc, Parameter p
where 
  mc.getMethodName() = "open" or 
  mc.getMethodName() = "os.path.join" or 
  mc.getMethodName() = "pathlib.PurePath.__add__"
  and p.getIndex() = 0
  and p.isVariable()
select mc, "Potential path injection vulnerability detected through unsafe file path construction."