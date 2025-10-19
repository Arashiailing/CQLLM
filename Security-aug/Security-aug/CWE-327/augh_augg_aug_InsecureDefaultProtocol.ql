/**
 * @name Insecure default SSL/TLS protocol version
 * @description Applications that fail to explicitly specify an SSL/TLS protocol version
 *              may rely on insecure default protocol versions, exposing them to known vulnerabilities.
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// This query detects deprecated SSL socket creation methods that do not explicitly define protocol versions.
// The ssl.wrap_socket function, when called without the ssl_version parameter, can default to insecure protocols.
// Related secure context configuration issues are covered by the py/insecure-protocol dataflow query.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode insecureSocketCall
where
  // Identify deprecated ssl.wrap_socket method calls
  insecureSocketCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Verify that the ssl_version parameter is missing
  and not exists(insecureSocketCall.getArgByName("ssl_version"))
select insecureSocketCall,
  "Use of deprecated ssl.wrap_socket without explicit protocol version may result in insecure default protocol selection."