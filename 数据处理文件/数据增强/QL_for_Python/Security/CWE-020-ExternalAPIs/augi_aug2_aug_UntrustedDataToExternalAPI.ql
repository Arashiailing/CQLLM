/**
 * @name Untrusted data passed to external API
 * @description Identifies security vulnerabilities where untrusted remote data flows
 *              into external API calls without proper sanitization.
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
  UntrustedDataToExternalApiFlow::PathNode taintedOrigin,  // Source of untrusted data
  UntrustedDataToExternalApiFlow::PathNode apiSink,         // Destination at API call
  ExternalApiUsedWithUntrustedData vulnerableApi           // Vulnerable API call
where
  // Confirm sink corresponds to API parameter receiving tainted input
  apiSink.getNode() = vulnerableApi.getUntrustedDataNode()
  and
  // Verify data flow path exists from source to sink
  UntrustedDataToExternalApiFlow::flowPath(taintedOrigin, apiSink)
select
  // Maintain original output format with enhanced variable references
  apiSink.getNode(), taintedOrigin, apiSink,
  "External API call to " + vulnerableApi.toString() + " receives untrusted data from $@.", taintedOrigin.getNode(),
  taintedOrigin.toString()