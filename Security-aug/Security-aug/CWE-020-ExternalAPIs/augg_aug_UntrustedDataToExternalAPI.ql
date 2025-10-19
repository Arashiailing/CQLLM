/**
 * @name Untrusted data passed to external API
 * @description Identifies security vulnerabilities where untrusted remote data
 *              is passed to external API calls without proper sanitization.
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
  UntrustedDataToExternalApiFlow::PathNode untrustedDataSource,  // Source of untrusted data flow
  UntrustedDataToExternalApiFlow::PathNode untrustedDataSink,     // Destination at API call site
  ExternalApiUsedWithUntrustedData vulnerableApiCall              // External API processing tainted data
where
  // Ensure the sink node corresponds to the API's parameter receiving untrusted data
  untrustedDataSink.getNode() = vulnerableApiCall.getUntrustedDataNode()
  and
  // Validate the existence of a data flow path from source to sink
  UntrustedDataToExternalApiFlow::flowPath(untrustedDataSource, untrustedDataSink)
select
  // Preserve original output format with enhanced variable naming
  untrustedDataSink.getNode(), untrustedDataSource, untrustedDataSink,
  "Call to " + vulnerableApiCall.toString() + " with untrusted data from $@.", untrustedDataSource.getNode(),
  untrustedDataSource.toString()