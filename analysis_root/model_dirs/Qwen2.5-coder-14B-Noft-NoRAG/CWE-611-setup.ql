import python

/**
 * This query detects CWE-611: XML external entity expansion (XXE) vulnerability
 * in Python code.
 */
from FunctionCall call, Argument arg
where call.getCallee().getName() = "parse" and
      call.getCallee().getDeclaringType().getName() = "xml.etree.ElementTree" and
      arg = call.getArgument(0) and
      not exists(Argument disableEntityArg |
        call.getArgumentIndex(disableEntityArg) > call.getArgumentIndex(arg) and
        disableEntityArg.getExpr() instanceof StringLiteral and
        disableEntityArg.getExpr().getValue() = " forbid_dtd=True "
      )
select call, "This call to xml.etree.ElementTree.parse may be vulnerable to XXE attacks because DTDs are not disabled."