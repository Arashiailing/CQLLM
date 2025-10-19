/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @kind problem
 * @id py/matrixfederationclient
 * @problem.severity warning
 * @precision high
 * @tags external/cwe/cwe-400
 */

import python
import semmle.python.dataflow.new.DataFlow
import FluentApiModel

from DataFlow::CallCfgNode apiClientCall, string clientName, Http::Client::Request request
where
  (
    apiClientCall = matrixFederationClientInstance().getMember("send").getACall() and
    clientName = "matrix_federation_client.send"
  )
  or
  (
    apiClientCall = matrixFederationClientInstance().getMember("sync").getACall() and
    clientName = "matrix_federation_client.sync"
  )
  and
  request = apiClientCall.getArg(0).(Http::Client::Request)
select apiClientCall.asExpr(), "Calling " + clientName + " creates an HTTP request to $@.", request,
  request.toString()