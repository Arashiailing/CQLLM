import semmle.code.py.PyCall
import semmle.code.py.PyString

from Call call, Variable var
where (call.getKind() = "Format" or call.getKind() = "Add")
  and var in call.getArgument(0).getExpression()
  and not exists (Call escapeCall |
    escapeCall.getKind() = "Call" and
    escapeCall.getFunction().getName() = "html.escape" and
    escapeCall.getArgument(0).getExpression() = var)
select call, "Potential reflected XSS vulnerability due to unescaped user input"