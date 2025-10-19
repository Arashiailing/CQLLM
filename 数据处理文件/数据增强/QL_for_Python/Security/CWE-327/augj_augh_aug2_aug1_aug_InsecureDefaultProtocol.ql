/**
 * @name Insecure default SSL/TLS protocol version
 * @description Detects SSL socket invocations that do not explicitly specify a protocol version,
 *              potentially leading to the use of insecure default protocols.
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// This query identifies deprecated ssl.wrap_socket method calls that fail to specify the ssl_version parameter.
// Omitting this parameter can result in the use of outdated and insecure SSL/TLS protocol versions by default.
// For comprehensive secure context analysis, refer to py/insecure-protocol dataflow query.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode insecureSslSocketCall
where
  // Define the target API call: ssl.wrap_socket
  API::moduleImport("ssl").getMember("wrap_socket").getACall() = insecureSslSocketCall
  // Verify the absence of the ssl_version parameter in the call
  and not exists(insecureSslSocketCall.getArgByName("ssl_version"))
select insecureSslSocketCall,
  "Use of deprecated ssl.wrap_socket without explicit protocol version may result in insecure default configuration."