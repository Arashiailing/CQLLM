/**
 * @name Insecure default SSL/TLS protocol version
 * @description Identifies SSL socket calls lacking explicit protocol version specification,
 *              which may default to insecure protocols.
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// This query detects deprecated ssl.wrap_socket invocations that omit the ssl_version parameter.
// Such omissions may lead to use of insecure default SSL/TLS protocol versions.
// For related secure context issues, see py/insecure-protocol dataflow analysis.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode unsafeSslWrapCall
where
  // Identify calls to ssl.wrap_socket method
  unsafeSslWrapCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Verify absence of ssl_version parameter
  and not exists(unsafeSslWrapCall.getArgByName("ssl_version"))
select unsafeSslWrapCall,
  "Deprecated ssl.wrap_socket call without protocol specification may use insecure default version."