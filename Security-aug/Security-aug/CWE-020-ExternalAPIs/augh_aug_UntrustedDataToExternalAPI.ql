/**
 * @name Untrusted data passed to external API
 * @description Identifies security vulnerabilities where untrusted remote user input
 *              flows directly into external API calls without proper sanitization.
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
  // Source node representing the entry point of untrusted data flow
  UntrustedDataToExternalApiFlow::PathNode untrustedDataSource,
  // Sink node representing the termination point at the vulnerable API call
  UntrustedDataToExternalApiFlow::PathNode apiSinkNode,
  // External API call that consumes the tainted data
  ExternalApiUsedWithUntrustedData vulnerableApiCall
where
  // Establish connection between sink node and the API's tainted parameter
  apiSinkNode.getNode() = vulnerableApiCall.getUntrustedDataNode()
  and
  // Verify complete data flow path exists from source to sink
  UntrustedDataToExternalApiFlow::flowPath(untrustedDataSource, apiSinkNode)
select
  // Preserve original output format with enhanced variable naming
  apiSinkNode.getNode(), untrustedDataSource, apiSinkNode,
  "Call to " + vulnerableApiCall.toString() + " with untrusted data from $@.", untrustedDataSource.getNode(),
  untrustedDataSource.toString()