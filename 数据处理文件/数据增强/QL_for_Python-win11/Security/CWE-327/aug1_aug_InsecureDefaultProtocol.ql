/**
 * @name Insecure default SSL/TLS protocol version
 * @description Failing to specify an SSL/TLS protocol version can lead to the use of
 *              an insecure default protocol.
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// This query identifies calls to deprecated SSL socket methods that omit protocol specification.
// When ssl.wrap_socket is invoked without the ssl_version parameter, it may fall back to insecure defaults.
// For related secure context configuration concerns, see py/insecure-protocol dataflow query.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode unsecureSocketInvocation
where
  // Check if the call is to ssl.wrap_socket method
  unsecureSocketInvocation = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Ensure the ssl_version parameter is not provided
  and not exists(unsecureSocketInvocation.getArgByName("ssl_version"))
select unsecureSocketInvocation,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."