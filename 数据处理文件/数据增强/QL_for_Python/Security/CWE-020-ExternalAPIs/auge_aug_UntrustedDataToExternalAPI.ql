/**
 * @name Untrusted data passed to external API
 * @description Identifies when untrusted data from remote sources is passed to external APIs without proper sanitization,
 *              which could result in security vulnerabilities.
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
  UntrustedDataToExternalApiFlow::PathNode sourceNode,     // Origin point of untrusted data flow
  UntrustedDataToExternalApiFlow::PathNode sinkNode,       // Termination point at API invocation
  ExternalApiUsedWithUntrustedData vulnerableApiCall       // External API consuming tainted data
where
  // Validate sink node corresponds to the API's untrusted parameter
  sinkNode.getNode() = vulnerableApiCall.getUntrustedDataNode()
  and
  // Ensure data propagation path exists from source to sink
  UntrustedDataToExternalApiFlow::flowPath(sourceNode, sinkNode)
select
  // Preserve original output structure with updated variable references
  sinkNode.getNode(), sourceNode, sinkNode,
  "Call to " + vulnerableApiCall.toString() + " with untrusted data from $@.", sourceNode.getNode(),
  sourceNode.toString()