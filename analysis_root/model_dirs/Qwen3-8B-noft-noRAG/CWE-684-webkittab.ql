import python
import semmle.code.cpp.dataflow.DataFlow

/** @name Reflective XSS Detection */
/**
 * Finds instances where user-controlled data is directly embedded into HTML output without proper escaping.
 * This can lead to reflected XSS vulnerabilities (CWE-684).
 */

from 
  PyFunctionCall call,
  PyStringLiteral stringLit,
  PyTemplateExpression templateExpr,
  PyVariableAccess varAccess
where
  call.getTarget().getName() = "print" or
  call.getTarget().getName() = "write" or
  call.getTarget().getName() = "render_template" or
  call.getTarget().getName() = "HttpResponse" and
  call.getArg(0) = stringLit and
  exists(PyTemplateExpression te | te = stringLit.getTemplate() and te.hasVariable(varAccess)) and
  varAccess.getSource().getKind() = "parameter" or
  varAccess.getSource().getKind() = "http_request"
select varAccess, "Potential reflected XSS vulnerability: User-controlled data is directly embedded in HTML output without proper escaping."