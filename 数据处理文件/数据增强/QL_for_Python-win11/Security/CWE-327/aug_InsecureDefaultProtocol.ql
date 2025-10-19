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

// This query detects deprecated SSL socket creation methods that don't specify protocols.
// When ssl.wrap_socket is called without ssl_version parameter, insecure defaults may be used.
// Related secure context configuration issues are covered by py/insecure-protocol dataflow query.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode insecureSocketCall
where
  // Identify deprecated ssl.wrap_socket method calls
  insecureSocketCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Verify ssl_version parameter is missing
  and not exists(insecureSocketCall.getArgByName("ssl_version"))
select insecureSocketCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."