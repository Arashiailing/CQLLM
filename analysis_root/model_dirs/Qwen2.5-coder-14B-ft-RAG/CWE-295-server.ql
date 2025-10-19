/**
 * @name CWE-295: Improper Certificate Validation
 * @description Request without certificate validation.Making a request without certificate validation can allow man-in-the-middle attacks.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/server-side-request-forgery
 * @tags correctness
 *       security
 *       external/cwe/cwe-918
 */

import python
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.DataFlow
import semmle.python.Concepts

from DataFlow::CallCfgNode http_client_call, string client_name
where
  (
    client_name = "urllib.request.urlopen" and
    http_client_call = API::moduleImport("urllib").getMember("request").getMember("urlopen").getACall()
  )
  or
  (
    client_name = "httplib.HTTPConnection.request" and
    http_client_call = API::moduleImport("httplib").getMember("HTTPConnection").getMember("request").getACall()
  )
  or
  (
    client_name = "http.client.HTTPConnection.request" and
    http_client_call = API::moduleImport("http").getMember("client").getMember("HTTPConnection").getMember("request").getACall()
  )
  or
  (
    client_name = "requests.request" and
    http_client_call = API::moduleImport("requests").getMember("request").getACall()
  )
  or
  (
    client_name = "requests.api.request" and
    http_client_call = any(API::Module req_mod |
      req_mod = API::moduleImport("requests") or
      req_mod = API::moduleImport("requests").getMember("api")
    ).getMember("request").getACall()
  )
select http_client_call.asExpr(), "Making a request using " + client_name + " without verifying the server's identity."