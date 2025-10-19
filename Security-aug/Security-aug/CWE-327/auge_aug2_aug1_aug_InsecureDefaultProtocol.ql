/**
 * @name Insecure default SSL/TLS protocol version
 * @description Identifies SSL socket invocations that lack explicit protocol version settings,
 *              potentially falling back to vulnerable protocol implementations.
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// This query detects insecure SSL socket configurations where protocol version is not specified.
// The ssl.wrap_socket method without ssl_version parameter may default to weak protocols.
// Refer to py/insecure-protocol dataflow query for additional secure context issues.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode vulnerableSslCall
where
  // The call targets ssl.wrap_socket method
  vulnerableSslCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // The ssl_version parameter is missing
  and not exists(vulnerableSslCall.getArgByName("ssl_version"))
select vulnerableSslCall,
  "Invocation of deprecated ssl.wrap_socket without explicit protocol version may default to insecure settings."