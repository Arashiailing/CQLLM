/**
 * @name Untrusted data passed to external API
 * @description Detects security vulnerabilities where untrusted remote user input flows into external API calls
 *              without proper validation or sanitization, potentially resulting in injection attacks,
 *              unauthorized access, or data leakage.
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
  UntrustedDataToExternalApiFlow::PathNode sourceNode,     // Source representing untrusted data entry point
  UntrustedDataToExternalApiFlow::PathNode sinkNode,       // Sink representing external API call site
  ExternalApiUsedWithUntrustedData vulnerableApiCall       // External API that processes untrusted input
where
  // Verify the sink node corresponds to the API parameter handling untrusted data
  sinkNode.getNode() = vulnerableApiCall.getUntrustedDataNode()
  and
  // Establish that a complete data flow path exists from the source to the sink
  UntrustedDataToExternalApiFlow::flowPath(sourceNode, sinkNode)
select
  // Output format: sink location, source node, sink node, message with source location, source description
  sinkNode.getNode(), sourceNode, sinkNode,
  "Call to " + vulnerableApiCall.toString() + " with untrusted data from $@.", sourceNode.getNode(),
  sourceNode.toString()