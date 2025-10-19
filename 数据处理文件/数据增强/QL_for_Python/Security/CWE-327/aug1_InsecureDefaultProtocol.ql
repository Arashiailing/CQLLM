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

// SSL/TLS connections are typically established using a security context that defines
// acceptable protocol versions. This query detects the deprecated practice of creating
// connections without referencing a context (via `ssl.wrap_socket`). When this method
// is invoked without explicitly specifying acceptable protocols, the connection will
// use the default settings which may be insecure.
//
// The detection of connections created with a context that hasn't been properly configured
// is handled by the data-flow query py/insecure-protocol.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode sslSocketCall
where
  // Identify invocations of the wrap_socket method from the ssl module
  sslSocketCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Check if the ssl_version parameter is missing from the call
  and not exists(sslSocketCall.getArgByName("ssl_version"))
select sslSocketCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."