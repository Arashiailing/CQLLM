/**
 * @name Default version of SSL/TLS may be insecure
 * @description Unspecified SSL/TLS version can lead to usage of insecure
 *              default protocols.
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// Connections are typically established using a context that specifies the acceptable
// protocol range. This query targets the deprecated practice of creating connections
// without a context (via `ssl.wrap_socket`). When this method is employed without
// explicitly setting the protocols, the connection falls back to insecure defaults.
//
// Note: Connections created with a misconfigured context are detected by the data-flow
// query py/insecure-protocol.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode wrapSocketCall
where 
  // Identify calls to ssl.wrap_socket
  wrapSocketCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Verify absence of ssl_version parameter
  and not exists(wrapSocketCall.getArgByName("ssl_version"))
select wrapSocketCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."