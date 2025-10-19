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

// This query detects deprecated SSL/TLS socket configurations lacking explicit protocol versioning.
// Unspecified ssl_version parameters in ssl.wrap_socket calls may trigger insecure protocol defaults.
// Focuses specifically on deprecated direct socket wrapping. For broader connection security analysis,
// refer to the py/insecure-protocol query.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode insecureSocketCall
where
  // Identify deprecated ssl.wrap_socket function calls
  insecureSocketCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  and
  // Verify absence of explicit ssl_version parameter specification
  not exists(insecureSocketCall.getArgByName("ssl_version"))
select insecureSocketCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."