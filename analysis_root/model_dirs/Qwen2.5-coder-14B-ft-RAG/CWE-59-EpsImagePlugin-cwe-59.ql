/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @description nan
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision medium
 * @id py/EpsImagePlugin-cwe-59
 * @tags correctness
 *       security
 *       external/cwe/cwe-59
 */

import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode eps_call, string prefix
where
  eps_call = API::moduleImport("PIL.EpsImagePlugin").getMember("EpsImagePlugin").getReturn()
  and
  exists(prefix |
    eps_call.getArg(0).getAValueReachableFromSource().asExpr().(StringLiteral).getText() =
      "%" + prefix + ".eps"
  )
select eps_call, "Potential unsafe link resolution in eps_image plugin."