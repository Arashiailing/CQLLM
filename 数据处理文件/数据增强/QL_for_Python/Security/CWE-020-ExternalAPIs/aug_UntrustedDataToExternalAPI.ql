/**
 * @name Untrusted data passed to external API
 * @description Detects untrusted remote data flowing into external API calls without sanitization,
 *              potentially leading to security vulnerabilities.
 * @id py/untrusted-data-to-external-api
 * @kind path-problem
 * @precision low
 * @problem.severity error
 * @security-severity 7.8
 * @tags security external/cwe/cwe-20
 */

import python
import ExternalAPIs
import UntrustedDataToExternalApiFlow::PathGraph

from
  UntrustedDataToExternalApiFlow::PathNode dataOrigin,  // Entry point of untrusted data flow
  UntrustedDataToExternalApiFlow::PathNode dataTarget,  // Termination point at API call
  ExternalApiUsedWithUntrustedData riskyApiCall         // External API consuming tainted data
where
  // Verify target node corresponds to the API's untrusted data parameter
  dataTarget.getNode() = riskyApiCall.getUntrustedDataNode()
  and
  // Confirm data flow path exists from origin to target
  UntrustedDataToExternalApiFlow::flowPath(dataOrigin, dataTarget)
select
  // Maintain original output structure with enhanced variable references
  dataTarget.getNode(), dataOrigin, dataTarget,
  "Call to " + riskyApiCall.toString() + " with untrusted data from $@.", dataOrigin.getNode(),
  dataOrigin.toString()