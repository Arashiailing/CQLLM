/**
 * @name Untrusted data passed to external API
 * @description Identifies security vulnerabilities where untrusted remote data flows into external API calls
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
  UntrustedDataToExternalApiFlow::PathNode untrustedDataOrigin,  // Source of untrusted data flow
  UntrustedDataToExternalApiFlow::PathNode apiCallSink,           // Destination at API call site
  ExternalApiUsedWithUntrustedData taintedApiCall                 // External API receiving tainted data
where
  // Ensure sink node corresponds to API parameter handling untrusted input
  apiCallSink.getNode() = taintedApiCall.getUntrustedDataNode()
  and
  // Confirm complete data flow path exists from source to sink
  UntrustedDataToExternalApiFlow::flowPath(untrustedDataOrigin, apiCallSink)
select
  // Maintain original output structure with enhanced variable references
  apiCallSink.getNode(), untrustedDataOrigin, apiCallSink,
  "Call to " + taintedApiCall.toString() + " with untrusted data from $@.", untrustedDataOrigin.getNode(),
  untrustedDataOrigin.toString()