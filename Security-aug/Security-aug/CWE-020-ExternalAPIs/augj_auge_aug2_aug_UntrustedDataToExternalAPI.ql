/**
 * @name Untrusted Data in External API Calls
 * @description Detects when untrusted data from external sources flows into external APIs
 *              without proper sanitization, potentially leading to security vulnerabilities.
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
  UntrustedDataToExternalApiFlow::PathNode untrustedDataSource,  // Origin of untrusted data
  UntrustedDataToExternalApiFlow::PathNode apiCallSink,           // Termination point at API call
  ExternalApiUsedWithUntrustedData vulnerableApiCall              // API consuming tainted data
where
  // Verify data flow path exists from source to sink
  UntrustedDataToExternalApiFlow::flowPath(untrustedDataSource, apiCallSink)
  and
  // Confirm sink node matches API's tainted parameter
  apiCallSink.getNode() = vulnerableApiCall.getUntrustedDataNode()
select
  // Maintain original output structure with updated variable references
  apiCallSink.getNode(), untrustedDataSource, apiCallSink,
  "Call to " + vulnerableApiCall.toString() + " with untrusted data from $@.", untrustedDataSource.getNode(),
  untrustedDataSource.toString()