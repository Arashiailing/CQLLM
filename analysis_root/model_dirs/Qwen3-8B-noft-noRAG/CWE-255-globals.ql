import python
import semmle.code.cpp.security.CredentialsManagement

from StringLiteral s, File f
where 
  s.getValue().matches(".*password|.*secret|.*key|.*token|.*credentials.*") and
  s.getDefinition().getContainingFile() = f and
  f.getName().matches(".*\.py$") and
  exists(WriteStmt w | w.getExpression().isAssignExpr() and
         w.getExpression().getVariable().getName() = "config" or
         w.getExpression().getVariable().getName() = "settings" or
         w.getExpression().getVariable().getName() = "env" and
         w.getExpression().getValue().toString() = s.getValue())
select s, "Potential CWE-255: Sensitive data stored in clear text."