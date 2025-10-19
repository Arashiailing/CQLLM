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

// This query detects deprecated SSL socket calls lacking protocol specification.
// When ssl.wrap_socket is invoked without ssl_version parameter, it may use
// insecure default protocols. For related secure context issues, see
// py/insecure-protocol dataflow query.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode insecureSocketCall
where
  // Identify calls to ssl.wrap_socket method
  insecureSocketCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Verify ssl_version parameter is not provided
  and not exists(insecureSocketCall.getArgByName("ssl_version"))
select insecureSocketCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."