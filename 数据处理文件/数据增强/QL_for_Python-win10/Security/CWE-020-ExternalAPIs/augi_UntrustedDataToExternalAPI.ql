/**
 * @name Untrusted data passed to external API
 * @description Data provided remotely is used in this external API without sanitization, which could be a security risk.
 * @id py/untrusted-data-to-external-api
 * @kind path-problem
 * @precision low
 * @problem.severity error
 * @security-severity 7.8
 * @tags security external/cwe/cwe-20
 */

// Import Python analysis libraries for code parsing and processing
import python
// Import external API identification utilities
import ExternalAPIs
// Import data flow path tracking framework
import UntrustedDataToExternalApiFlow::PathGraph

// Identify vulnerable data flows from untrusted sources to external APIs
from
  UntrustedDataToExternalApiFlow::PathNode untrustedSource, // Origin point of untrusted data
  UntrustedDataToExternalApiFlow::PathNode apiSink,         // Destination point at external API
  ExternalApiUsedWithUntrustedData riskyExternalApi         // External API consuming untrusted data
where
  // Ensure sink node corresponds to the untrusted data used in the external API call
  apiSink.getNode() = riskyExternalApi.getUntrustedDataNode() and
  // Verify complete data flow path exists from source to sink
  UntrustedDataToExternalApiFlow::flowPath(untrustedSource, apiSink)
select
  // Report findings with path details and contextual information
  apiSink.getNode(), untrustedSource, apiSink,
  "Call to " + riskyExternalApi.toString() + " with untrusted data from $@.", untrustedSource.getNode(),
  untrustedSource.toString()