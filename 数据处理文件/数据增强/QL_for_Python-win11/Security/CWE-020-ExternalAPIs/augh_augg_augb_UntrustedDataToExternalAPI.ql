/**
 * @name Untrusted data passed to external API
 * @description Detects when untrusted remote data flows to external APIs without sanitization
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
  UntrustedDataToExternalApiFlow::PathNode untrustedSourceNode,
  UntrustedDataToExternalApiFlow::PathNode vulnerableSinkNode,
  ExternalApiUsedWithUntrustedData externalApiCall
where
  // Connect sink node to external API call
  vulnerableSinkNode.getNode() = externalApiCall.getUntrustedDataNode()
  and
  // Verify data flow from untrusted source to vulnerable sink
  UntrustedDataToExternalApiFlow::flowPath(untrustedSourceNode, vulnerableSinkNode)
select
  vulnerableSinkNode.getNode(), 
  untrustedSourceNode, 
  vulnerableSinkNode,
  "Call to " + externalApiCall.toString() + " with untrusted data from $@.", 
  untrustedSourceNode.getNode(),
  untrustedSourceNode.toString()