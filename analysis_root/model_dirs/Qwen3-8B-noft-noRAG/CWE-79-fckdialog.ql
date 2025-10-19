import python

/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @id py/fckdialog
 */

from PyFunctionCall call, PyString s, PyExpression expr
where call.isReturn() and
      s = call.getArgument(0) and
      s.hasPart(expr) and
      expr.isName() and
      expr.getName().getUnderlyingName() is (call.getModule().getName() + ".request" or
                                             call.getModule().getName() + ".request.args")
select expr, "Potential reflected XSS vulnerability: User input is directly output without escaping."