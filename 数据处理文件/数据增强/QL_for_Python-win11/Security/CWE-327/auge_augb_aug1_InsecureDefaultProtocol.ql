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

// This query identifies security vulnerabilities in SSL/TLS configurations by
// detecting calls to ssl.wrap_socket that do not explicitly specify the ssl_version
// parameter. Omitting this parameter may result in the use of insecure default
// protocols, potentially exposing the application to cryptographic weaknesses.
// For additional protocol-related security checks, refer to py/insecure-protocol.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode insecureSslWrapCall
where
  // Locate calls to the ssl.wrap_socket method
  insecureSslWrapCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Verify that the ssl_version parameter is missing
  and not exists(insecureSslWrapCall.getArgByName("ssl_version"))
select insecureSslWrapCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."