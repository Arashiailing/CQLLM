/**
 * @name Insecure default SSL/TLS protocol version
 * @description Failing to specify an SSL/TLS protocol version can lead to the use of
 *              an insecure default protocol version.
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// This query identifies deprecated SSL socket creation methods that omit protocol specifications.
// When ssl.wrap_socket is invoked without the ssl_version parameter, it may fall back to insecure defaults.
// Additional secure context configuration issues are addressed by the py/insecure-protocol dataflow query.
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode unspecifiedProtocolCall
where
  // Locate calls to the deprecated ssl.wrap_socket method
  unspecifiedProtocolCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Confirm absence of the ssl_version parameter
  and not exists(unspecifiedProtocolCall.getArgByName("ssl_version"))
select unspecifiedProtocolCall,
  "Invocation of deprecated ssl.wrap_socket without specifying a protocol version may lead to insecure default protocol usage."