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

// SSL/TLS connections require explicit protocol configuration to ensure security.
// This query identifies deprecated usage of `ssl.wrap_socket` calls where the 
// `ssl_version` parameter is omitted. Such omissions lead to insecure default 
// protocol usage. For context-based configuration issues, see py/insecure-protocol.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode insecureSslCall
where
  // Locate calls to ssl.wrap_socket without explicit protocol specification
  insecureSslCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  and not exists(insecureSslCall.getArgByName("ssl_version"))
select insecureSslCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."