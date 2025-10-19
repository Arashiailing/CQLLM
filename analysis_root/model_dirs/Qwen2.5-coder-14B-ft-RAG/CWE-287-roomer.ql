/**
 * @name CWE-287: Improper Authentication
 * @description When an actor claims to have a given identity, the product does not prove or insufficiently proves that the claim is correct.
 * @kind problem
 * @problem.severity error
 * @security-severity 8.1
 * @precision medium
 * @id py/roomer
 * @tags correctness
 *       security
 *       external/cwe/cwe-287
 */

import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode authCall, string authMechanismName
where
  (
    authCall = API::moduleImport("flask_httpauth").getMember("HTTPBasicAuth").getReturn()
     .getMember("authenticate").getACall()
    or
    authCall = API::moduleImport("flask_httpauth").getMember("HTTPDigestAuth").getReturn()
     .getMember("authenticate").getACall()
  )
  and
  authMechanismName =
    (
      authCall.getFunc().getScope().getName() = "HTTPBasicAuth" and "basic authentication"
      or
      authCall.getFunc().getScope().getName() = "HTTPDigestAuth" and "digest authentication"
    )
select authCall.asExpr(), "This authentication mechanism uses " + authMechanismName + "."