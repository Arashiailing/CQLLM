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

// Typically, connections are established using a context that defines the acceptable
// protocol range. This query identifies the deprecated method of creating connections
// without a context reference (via `ssl.wrap_socket`). When this approach is used
// without explicitly specifying acceptable protocols, connections will default to
// insecure settings.
//
// The detection of connections created with an improperly configured context is
// addressed by the data-flow query py/insecure-protocol.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode socketCall
where
  // Identify calls to ssl.wrap_socket
  socketCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Verify absence of ssl_version parameter
  and not exists(socketCall.getArgByName("ssl_version"))
select socketCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."