/**
 * @name CWE-284: Improper Access Control
 * @description nan
 * @kind problem
 * @id py/RegistrationTool
 * @problem.severity warning
 * @tags reliability
 */

import python
import semmle.python.ApiGraphs

// Helper functions to check if a node represents specific APIs
predicate isUserRegistrationApi(API::Node api) {
  api = API::moduleImport("registration").getMember("register_user")
}

predicate isServiceStartApi(API::Node api) {
  api = API::moduleImport("service").getMember("start_service")
}

// Main query finding calls to register_user without appropriate access control
from DataFlow::CallCfgNode registerCall, DataFlow::CallCfgNode serviceCall
where
  // Identify the registration function call
  registerCall = isUserRegistrationApi(api).getACall()
  and
  // Ensure there's no preceding service start call
  not (
    serviceCall = isServiceStartApi(api).getACall()
    and
    serviceCall.getScope() = registerCall.getScope()
    and
    serviceCall.getAnArg().getAFlowReachingSink().asExpr().(StringLiteral)
      = registerCall.getArg(0)
  )
select registerCall.asExpr(),
  "This call to register_user does not appear to have proper authorization checks."