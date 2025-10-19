/**
 * @name Untrusted data passed to external API
 * @description Detects untrusted data from remote sources being passed to external APIs
 *              without sanitization, potentially leading to security vulnerabilities.
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
  UntrustedDataToExternalApiFlow::PathNode untrustedSourceNode,  // Entry point of tainted data flow
  UntrustedDataToExternalApiFlow::PathNode vulnerableSinkNode,   // API invocation consuming tainted data
  ExternalApiUsedWithUntrustedData taintedApiCall                // External API handling untrusted input
where
  // Validate sink node corresponds to the API's tainted parameter
  vulnerableSinkNode.getNode() = taintedApiCall.getUntrustedDataNode()
  and
  // Verify data propagation path exists from source to sink
  UntrustedDataToExternalApiFlow::flowPath(untrustedSourceNode, vulnerableSinkNode)
select
  // Maintain original output structure with renamed variables
  vulnerableSinkNode.getNode(), untrustedSourceNode, vulnerableSinkNode,
  "Call to " + taintedApiCall.toString() + " with untrusted data from $@.", untrustedSourceNode.getNode(),
  untrustedSourceNode.toString()