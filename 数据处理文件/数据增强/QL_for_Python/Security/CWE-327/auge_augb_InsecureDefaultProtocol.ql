/**
 * @name Default version of SSL/TLS may be insecure
 * @description Unspecified SSL/TLS version can lead to usage of insecure
 *              default protocols.
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// This query detects deprecated SSL socket creation methods that lack explicit protocol specification.
// The ssl.wrap_socket() method without ssl_version parameter defaults to potentially insecure protocols.
// Note: Context-based insecure configurations are handled by separate query py/insecure-protocol.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode insecureSocketCall
where 
  // Identify deprecated ssl.wrap_socket() method calls
  insecureSocketCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Ensure no explicit protocol version is specified
  and not exists(insecureSocketCall.getArgByName("ssl_version"))
select insecureSocketCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."