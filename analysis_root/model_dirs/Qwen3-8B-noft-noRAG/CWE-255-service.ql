@name CWE-255: Credentials Management Errors
@description Detects potential credential management errors such as hardcoded secrets, insecure storage, and improper handling of authentication data.
@id py/service

import python
import semmle.code.python.Strings
import semmle.code.python.ControlFlow

from StringLiteral sl, FunctionCall fc
where 
  sl.getValue().matches(".*password.*|.*secret.*|.*key.*|.*token.*|.*credentials.*") and
  (fc.getTarget() = sl or exists(VariableDecl vd | vd.getInitializer() = sl)) and
  fc.getName() = "get" or fc.getName() = "post" or fc.getName() = "put" or fc.getName() = "patch"
select sl, "Potential credential management error detected: Hardcoded or improperly handled credentials found in network request."