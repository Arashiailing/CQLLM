/**
 * @name Untrusted data passed to external API
 * @description Detects security vulnerabilities where untrusted remote user input flows 
 *              into external API parameters without proper sanitization, potentially causing 
 *              injection attacks or data exposure
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
  UntrustedDataToExternalApiFlow::PathNode untrustedSource,  // Origin point of untrusted data flow
  UntrustedDataToExternalApiFlow::PathNode apiSink,           // Destination point at API invocation
  ExternalApiUsedWithUntrustedData vulnerableApiCall          // External API receiving tainted input
where
  // Verify complete data flow path exists from source to sink
  UntrustedDataToExternalApiFlow::flowPath(untrustedSource, apiSink)
  and
  // Confirm sink node corresponds to API parameter handling untrusted data
  apiSink.getNode() = vulnerableApiCall.getUntrustedDataNode()
select
  // Maintain original output structure with enhanced variable references
  apiSink.getNode(), untrustedSource, apiSink,
  "Call to " + vulnerableApiCall.toString() + " with untrusted data from $@.", untrustedSource.getNode(),
  untrustedSource.toString()