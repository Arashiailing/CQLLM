import python

/**
 * CWE-611: XML External Entity (XXE) Expansion
 * 
 * This query detects instances where user input is parsed as an XML document
 * with external entity expansion enabled, which can lead to XXE attacks.
 */

from FunctionCall fc, Argument arg
where fc.getCallee().getName() = "parse" and
      fc.getCallee().getDeclaringType().getName() = "xml.etree.ElementTree" and
      arg = fc.getArgument(0) and
      not exists(DataFlow::PathNode src, DataFlow::PathNode sink |
        DataFlow::localFlow(src, sink) and
        src.asExpr() = arg and
        sink.asExpr().(StringLiteral).getValue() = "DTD"
      )
select arg, "This XML parsing function may be vulnerable to XXE attacks."