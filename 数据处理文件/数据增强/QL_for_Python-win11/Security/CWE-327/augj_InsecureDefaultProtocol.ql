/**
 * @name Default version of SSL/TLS may be insecure
 * @description Failing to explicitly specify the SSL/TLS protocol version may lead to
 *              the use of insecure default protocol settings.
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// SSL/TLS connections are typically established using a security context that defines
// the permitted protocol versions. This query identifies the deprecated approach of
// creating connections without a security context (using `ssl.wrap_socket`). When this
// method is used without explicitly specifying acceptable protocols, the connection
// defaults to potentially insecure settings.
//
// Note: Detection of connections created with improperly configured security contexts
// is handled by the data-flow query py/insecure-protocol.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode insecureSocketCall
where
  // Identify calls to the wrap_socket method in the ssl module
  insecureSocketCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  and
  // Verify that the ssl_version parameter is not provided
  not exists(insecureSocketCall.getArgByName("ssl_version"))
select insecureSocketCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."