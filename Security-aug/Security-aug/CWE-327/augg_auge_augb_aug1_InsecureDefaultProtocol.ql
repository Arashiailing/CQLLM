/**
 * @name Default version of SSL/TLS may be insecure
 * @description Leaving the SSL/TLS version unspecified may result in an insecure
 *              default protocol being used.
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// This query identifies security vulnerabilities in SSL/TLS configurations by:
// 1. Locating calls to ssl.wrap_socket method
// 2. Verifying that the ssl_version parameter is missing in these calls
// Omitting this parameter may result in using insecure default protocols,
// potentially exposing the application to cryptographic weaknesses.
// For additional protocol-related security checks, refer to py/insecure-protocol.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode sslWrapCallWithoutVersion
where
  // Step 1: Identify calls to ssl.wrap_socket method
  sslWrapCallWithoutVersion = API::moduleImport("ssl")
                            .getMember("wrap_socket")
                            .getACall()
  // Step 2: Verify ssl_version parameter is absent
  and not exists(sslWrapCallWithoutVersion.getArgByName("ssl_version"))
select sslWrapCallWithoutVersion,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."