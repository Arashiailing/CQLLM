/**
 * @name Untrusted Data in External API Calls
 * @description Identifies when untrusted data from external sources is passed to external APIs
 *              without proper sanitization, which may result in security vulnerabilities.
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
  UntrustedDataToExternalApiFlow::PathNode taintedSource,  // Origin of untrusted data flow
  UntrustedDataToExternalApiFlow::PathNode apiSink,         // Termination at API call site
  ExternalApiUsedWithUntrustedData riskyApiCall            // External API consuming tainted data
where
  // Validate existence of data flow path from source to sink
  UntrustedDataToExternalApiFlow::flowPath(taintedSource, apiSink)
  and
  // Verify sink node corresponds to the API's parameter receiving untrusted input
  apiSink.getNode() = riskyApiCall.getUntrustedDataNode()
select
  // Preserve original output structure with enhanced variable references
  apiSink.getNode(), taintedSource, apiSink,
  "Call to " + riskyApiCall.toString() + " with untrusted data from $@.", taintedSource.getNode(),
  taintedSource.toString()