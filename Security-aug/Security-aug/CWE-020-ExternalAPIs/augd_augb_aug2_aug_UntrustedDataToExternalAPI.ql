/**
 * @name Untrusted data passed to external API
 * @description Detects security vulnerabilities where untrusted remote data flows into external API calls
 *              without proper sanitization, potentially leading to injection attacks or data breaches.
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
  UntrustedDataToExternalApiFlow::PathNode untrustedDataSource,  // Origin point of untrusted data
  UntrustedDataToExternalApiFlow::PathNode apiCallSinkNode,       // API call site receiving tainted data
  ExternalApiUsedWithUntrustedData taintedExternalApiCall          // External API call with untrusted input
where
  // Establish sink node corresponds to API parameter handling untrusted data
  apiCallSinkNode.getNode() = taintedExternalApiCall.getUntrustedDataNode()
  and
  // Verify complete data flow path exists from source to sink
  UntrustedDataToExternalApiFlow::flowPath(untrustedDataSource, apiCallSinkNode)
select
  // Preserve original output structure with enhanced variable references
  apiCallSinkNode.getNode(), untrustedDataSource, apiCallSinkNode,
  "Call to " + taintedExternalApiCall.toString() + " with untrusted data from $@.", untrustedDataSource.getNode(),
  untrustedDataSource.toString()