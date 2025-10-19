/**
 * @name Insecure default SSL/TLS protocol version
 * @description Failing to specify an SSL/TLS protocol version can lead to the use of
 *              an insecure default protocol.
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// This analysis detects insecure SSL socket configurations by identifying
// ssl.wrap_socket calls that omit the ssl_version parameter. Such omissions
// may result in the system defaulting to deprecated or weak protocols.
// For comprehensive SSL/TLS security analysis, see py/insecure-protocol.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode insecureSslWrapCall
where
  // Identify ssl.wrap_socket method invocations
  insecureSslWrapCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Verify absence of ssl_version parameter specification
  and not exists(insecureSslWrapCall.getArgByName("ssl_version"))
select insecureSslWrapCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."