/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description nan
 * @kind problem
 * @id py/sosreport
 * @problem.severity error
 * @tags security
 *       external/cwe/cwe-200
 */

import python
import semmle.python.ApiGraphs

predicate isSensitiveOperation(API::Node apiNode) {
  exists(string operationName |
    operationName = "write" and
    (
      apiNode = API::moduleImport("os").getMember(operationName)
      or
      apiNode = API::moduleImport("sys").getMember("stderr").getMember(operationName)
    )
  )
}

from Expr callExpr, string sensitiveDataDescription, DataFlow::Node dataSrc
where
  isSensitiveOperation(callExpr.(Call).getFunc()) and
  dataSrc = callExpr.getArg(0).asExpr() and
  sensitiveDataDescription = dataSrc.toString()
select callExpr,
  "A $@ operation writes sensitive information to standard error.", dataSrc,
  sensitiveDataDescription