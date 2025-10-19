/**
 * @name Default version of SSL/TLS may be insecure
 * @description Omitting explicit SSL/TLS protocol configuration may lead to 
 *              insecure default protocol usage. This query detects deprecated 
 *              `ssl.wrap_socket` calls lacking the `ssl_version` parameter.
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// Explicit protocol configuration is required for secure SSL/TLS connections.
// This analysis identifies deprecated `ssl.wrap_socket` invocations where
// the `ssl_version` parameter is missing, potentially leading to insecure defaults.
// For context-based protocol issues, see py/insecure-protocol.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode vulnerableSslInvocation
where
  // Identify calls to ssl.wrap_socket without explicit protocol specification
  vulnerableSslInvocation = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  and not exists(vulnerableSslInvocation.getArgByName("ssl_version"))
select vulnerableSslInvocation,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."