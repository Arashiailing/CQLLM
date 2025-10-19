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

// Modern SSL/TLS connections should use protocol contexts to control acceptable protocols.
// This query detects deprecated direct socket wrapping via `ssl.wrap_socket` without context.
// When called without specifying `ssl_version`, connections use insecure default protocols.
// Note: Context-based configuration issues are handled by py/insecure-protocol data-flow query.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode insecureSocketCall
where
  // Identify deprecated direct socket wrapping calls
  insecureSocketCall = API::moduleImport("ssl").getMember("wrap_socket").getACall() and
  // Verify no explicit protocol version was specified
  not exists(insecureSocketCall.getArgByName("ssl_version"))
select insecureSocketCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."