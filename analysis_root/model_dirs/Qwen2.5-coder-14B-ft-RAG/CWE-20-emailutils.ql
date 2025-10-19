/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id py/emailutils
 * @tags correctness
 *       security
 */

import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode emailutilParseCall,
     DataFlow::Node emailutilParam,
     string paramDesc
where
  (
    emailutilParam = emailutilParseCall.getArg(0) and
    paramDesc = "first argument"
  )
  or
  (
    emailutilParam = emailutilParseCall.getArg(1) and
    paramDesc = "second argument"
  )
  and
  emailutilParseCall = API::moduleImport("email.utils").getMember("parseaddr").getACall()
select emailutilParseCall.asExpr(),
  "$@ to this function may be controlled by an unauthenticated user.",
  emailutilParam, paramDesc