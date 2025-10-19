/**
 * @name CWE-287: Improper Authentication
 * @description When an actor claims to have a given identity, the product does not prove or insufficiently proves that the claim is correct.
 * @kind path-problem
 * @id py/basic_auth
 * @precision medium
 * @problem.severity error
 * @tags security
 *       external/cwe/cwe-287
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode auth_call,
     DataFlow::Node user_input_node,
     string message
where
  // Check if the authentication method is basic authentication
  (
    auth_call = API::moduleImport("http.server").getMember("BaseHTTPRequestHandler")
              .getMember("handle_basic_auth").getACall()
    and
    message = "basic authentication"
  )
  or
  (
    auth_call = API::moduleImport("wsgiref.simple_server").getMember("WSGIRequestHandler")
              .getMember("handle_basic_auth").getACall()
    and
    message = "basic authentication"
  )
  or
  (
    auth_call = API::moduleImport("flask").getMember("request").getMember("authenticate")
              .getACall()
    and
    message = "Flask authentication"
  )
  or
  (
    auth_call = API::moduleImport("django.http").getMember("HttpRequest").getMember("authenticate")
              .getACall()
    and
    message = "Django authentication"
  )
  and
  // Verify that there is user-controlled input in the authentication process
  (
    user_input_node = auth_call.getArg(0)
    or
    user_input_node = auth_call.getArg(1)
  )
select auth_call, "This HTTP server performs " + message + " without validating credentials."