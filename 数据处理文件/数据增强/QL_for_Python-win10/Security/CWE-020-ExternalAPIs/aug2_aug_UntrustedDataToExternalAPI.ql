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
  UntrustedDataToExternalApiFlow::PathNode untrustedDataSource,  // Origin of untrusted data flow
  UntrustedDataToExternalApiFlow::PathNode apiSinkNode,            // Termination at API call site
  ExternalApiUsedWithUntrustedData vulnerableApiCall              // External API consuming tainted data
where
  // Verify sink node corresponds to the API's parameter receiving untrusted input
  apiSinkNode.getNode() = vulnerableApiCall.getUntrustedDataNode()
  and
  // Validate existence of data flow path from source to sink
  UntrustedDataToExternalApiFlow::flowPath(untrustedDataSource, apiSinkNode)
select
  // Preserve original output structure with enhanced variable references
  apiSinkNode.getNode(), untrustedDataSource, apiSinkNode,
  "Call to " + vulnerableApiCall.toString() + " with untrusted data from $@.", untrustedDataSource.getNode(),
  untrustedDataSource.toString()