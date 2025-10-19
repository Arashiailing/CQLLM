/**
 * @name Insecure default SSL/TLS protocol version
 * @description Identifies SSL socket invocations lacking explicit protocol version configuration,
 *              potentially defaulting to vulnerable protocols.
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// This query detects deprecated SSL socket calls that omit protocol version parameters.
// When ssl.wrap_socket is invoked without ssl_version, insecure protocol defaults may apply.
// For related secure context issues, refer to py/insecure-protocol dataflow analysis.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode vulnerableSslInvocation
where
  // Target identification: ssl.wrap_socket method calls
  vulnerableSslInvocation = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Parameter validation: absence of ssl_version configuration
  and not exists(vulnerableSslInvocation.getArgByName("ssl_version"))
select vulnerableSslInvocation,
  "Deprecated ssl.wrap_socket invocation without protocol specification may use insecure default version."