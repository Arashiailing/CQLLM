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

// This query identifies deprecated SSL socket creation methods that lack protocol specification.
// When ssl.wrap_socket is invoked without the ssl_version parameter, insecure defaults may be applied.
// Note: Secure context configuration issues are covered by py/insecure-protocol dataflow query.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode insecureSslSocketCall
where
  // Target deprecated ssl.wrap_socket method invocations
  insecureSslSocketCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Confirm absence of ssl_version parameter in the call
  and not exists(insecureSslSocketCall.getArgByName("ssl_version"))
select insecureSslSocketCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."