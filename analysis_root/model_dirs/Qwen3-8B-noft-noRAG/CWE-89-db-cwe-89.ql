import python
import semmle.code.java.dataflow.DataFlow
import semmle.code.python.strings.StringHandling

from MethodCall call, StringLiteral sqlLit, Variable var
where 
  call.getMethodName() = "execute" and 
  call.getCallee().getQualifiedName() = "sqlite3.Cursor.execute" and 
  exists(StringConcatenation conc where conc.getBase() = call.getArg(0)) and 
  var = conc.getRightOperand()
select call, "Potential SQL injection vulnerability via string concatenation in SQL query"