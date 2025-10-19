/**
 * @name Default version of SSL/TLS may be insecure
 * @description Using deprecated SSL socket methods without explicit protocol
 *              specification can lead to insecure default configurations.
 *              Attackers may exploit weak protocols like SSLv2/SSLv3 or TLS 1.0/1.1.
 * @id py/insecure-default-protocol
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

// This query identifies deprecated SSL socket creation patterns where:
// 1. The ssl.wrap_socket() method is used (deprecated since Python 3.7)
// 2. No explicit ssl_version parameter is specified
// 3. This may result in using insecure default protocols (e.g., SSLv3)
// Note: Secure context issues are covered by py/insecure-protocol dataflow query
import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode deprecatedSocketCall
where
  // Identify deprecated ssl.wrap_socket method calls
  deprecatedSocketCall = API::moduleImport("ssl").getMember("wrap_socket").getACall()
  // Verify ssl_version parameter is missing
  and not exists(deprecatedSocketCall.getArgByName("ssl_version"))
select deprecatedSocketCall,
  "Call to deprecated method ssl.wrap_socket does not specify a protocol, which may result in an insecure default being used."