/**
 * @name Insecure default SSL/TLS protocol version
 * @description Detects SSL socket calls without explicit protocol version specification,
 *              which may default to insecure protocols.
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// This query identifies deprecated SSL socket calls that omit protocol version specification.
// When ssl.wrap_socket is called without ssl_version parameter, it may use insecure defaults.
// For related secure context configuration issues, see py/insecure-protocol dataflow query.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode insecureSocketCall
where
  // Verify the call targets ssl.wrap_socket method
  insecureSocketCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Confirm ssl_version parameter is missing
  and not exists(insecureSocketCall.getArgByName("ssl_version"))
select insecureSocketCall,
  "Call to deprecated ssl.wrap_socket without protocol specification may use insecure default version."