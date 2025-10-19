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

// This analysis identifies potentially insecure SSL socket configurations.
// It specifically targets ssl.wrap_socket calls that omit the ssl_version parameter,
// which could result in the system defaulting to weak or deprecated protocols.
// For a broader analysis of SSL/TLS security issues, refer to the
// py/insecure-protocol dataflow query.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode vulnerableSocketCall
where
  // Locate invocations of the ssl.wrap_socket method
  vulnerableSocketCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Check if the ssl_version parameter is absent
  and not exists(vulnerableSocketCall.getArgByName("ssl_version"))
select vulnerableSocketCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."