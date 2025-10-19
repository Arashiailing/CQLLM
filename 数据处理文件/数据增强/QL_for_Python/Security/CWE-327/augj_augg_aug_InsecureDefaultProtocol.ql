/**
 * @name Insecure default SSL/TLS protocol version
 * @description Applications that create SSL sockets without explicitly specifying
 *              a secure protocol version may rely on insecure defaults.
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// This query detects insecure SSL socket configurations where the protocol version is not specified.
// When ssl.wrap_socket is called without the ssl_version parameter, it may use outdated protocols
// that are vulnerable to attacks. Note that broader SSL/TLS security issues are covered by
// the py/insecure-protocol dataflow analysis.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode insecureSocketCall
where
  // Identify calls to the deprecated ssl.wrap_socket function
  insecureSocketCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Ensure the ssl_version parameter is not provided
  and not exists(insecureSocketCall.getArgByName("ssl_version"))
select insecureSocketCall,
  "Use of deprecated ssl.wrap_socket without explicit protocol version may result in insecure default protocol selection."