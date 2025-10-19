/**
* @name URL redirection from remote source
* @description URL redirection based on unvalidated user input
*              may cause redirection to malicious web sites.
* @id py/matrix_federation_agent
* @kind problem
* @precision high
* @problem.severity warning
* @security-severity 7.8
* @tags security
*/

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

predicate is_matrix_federation_agent(DataFlow::Node n) {
  (
    n = API::moduleImport("matrix_federation_agent")
     .getMember("MatrixFederationAgent")
     .getReturn()
  )
  or
  (
    n = API::moduleImport("synapse.federation.transport.server")
     .getMember("ServerTransport")
     .getReturn()
  )
}

DataFlow::Node matrix_federation_agent_request_arg(int pos) {
  (result = API::moduleImport("matrix_federation_agent")
    .getMember("MatrixFederationAgent")
    .getReturn()
    .getMember("on_incoming_headers")
    .getReturn()
    .getMember("invoke")
    .getReturn()
    .getArg(pos)) and
  pos in [1, 2]
  or
  (result = API::moduleImport("synapse.federation.transport.server")
    .getMember("ServerTransport")
    .getReturn()
    .getMember("on_incoming_headers")
    .getReturn()
    .getMember("invoke")
    .getReturn()
    .getArg(pos)) and
  pos in [1, 2]
}

from DataFlow::Node request, DataFlow::Node user_input
where
  is_matrix_federation_agent(request) and
  user_input = matrix_federation_agent_request_arg(1)
select request,
  "This Matrix federation agent processing depends on a $@.",
  user_input, user_input.toString()