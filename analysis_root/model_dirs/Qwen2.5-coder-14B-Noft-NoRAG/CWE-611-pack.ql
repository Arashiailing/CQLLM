import python

/**
 * Detects CWE-611: XML external entity expansion (XXE) vulnerability.
 */
from FunctionCall call, Argument arg
where call.getCallee().getName() = "parse" and
      call.getCallee().getDeclaringType().getName() = "xml.etree.ElementTree" and
      arg = call.getArgument(0) and
      not exists(Argument disableArg |
        call.getArgument(disableArg.getIndex()) = disableArg and
        disableArg.getValue().asConstantString() = " forbid_dtd"
      )
select call, "This XML parsing function is vulnerable to XXE attacks because external entity expansion is enabled."