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

// This query identifies deprecated SSL/TLS socket configurations lacking explicit protocol versioning.
// Unspecified ssl_version parameters in ssl.wrap_socket calls may trigger insecure protocol defaults.
// Focuses specifically on deprecated direct socket wrapping. For broader connection security analysis,
// refer to the py/insecure-protocol query.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode deprecatedSocketWrapCall
where
  // Identify all calls to the deprecated ssl.wrap_socket function
  deprecatedSocketWrapCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  and
  // Ensure no explicit ssl_version parameter is specified
  not exists(deprecatedSocketWrapCall.getArgByName("ssl_version"))
select deprecatedSocketWrapCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."