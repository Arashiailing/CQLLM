/**
 * @name Insecure default SSL/TLS protocol version
 * @description Detects SSL/TLS connections using insecure default protocols due to missing version specification.
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// Identifies deprecated SSL socket calls that omit protocol version specification.
// When ssl.wrap_socket is called without ssl_version parameter, it may default to
// vulnerable protocols. For related secure context analysis, refer to
// py/insecure-protocol dataflow query.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode unsecureSocketInvocation
where
  // Locate calls to ssl.wrap_socket method
  unsecureSocketInvocation.getNode() = API::moduleImport("ssl").getMember("wrap_socket").getACall().getNode()
  // Ensure ssl_version parameter is absent
  and not exists(unsecureSocketInvocation.getArgByName("ssl_version"))
select unsecureSocketInvocation,
  "Deprecated ssl.wrap_socket call lacks protocol specification, potentially enabling insecure default protocols."