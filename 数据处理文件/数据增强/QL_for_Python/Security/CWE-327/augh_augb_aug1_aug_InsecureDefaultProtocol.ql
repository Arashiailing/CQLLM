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

// This query identifies deprecated SSL socket calls that lack protocol specification.
// When ssl.wrap_socket is called without the ssl_version parameter, it may fall back
// to using insecure default protocols. For comprehensive secure context analysis,
// refer to the py/insecure-protocol dataflow query.
import python
import semmle.python.ApiGraphs

// Define the SSL module and its wrap_socket method for clarity
from DataFlow::CallCfgNode unsafeSocketInvocation
where
  // Locate all invocations of the ssl.wrap_socket method
  unsafeSocketInvocation = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Ensure that the ssl_version parameter is explicitly omitted
  and not exists(unsafeSocketInvocation.getArgByName("ssl_version"))
select unsafeSocketInvocation,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."