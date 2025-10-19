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

// This query detects insecure SSL/TLS socket configurations where the protocol version
// is not explicitly specified. Using ssl.wrap_socket without setting ssl_version may
// lead to the system defaulting to weak protocols.
//
// This check specifically targets the deprecated direct socket wrapping approach.
// For context-based connection security analysis, see the py/insecure-protocol query.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode insecureSocketCall
where
  // Locate all calls to the deprecated ssl.wrap_socket function
  insecureSocketCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  and
  // Verify that no explicit ssl_version parameter is provided
  not exists(insecureSocketCall.getArgByName("ssl_version"))
select insecureSocketCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."