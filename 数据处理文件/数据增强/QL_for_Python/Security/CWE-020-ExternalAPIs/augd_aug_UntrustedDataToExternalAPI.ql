/**
 * @name Untrusted data passed to external API
 * @description Identifies security risks where untrusted remote input is directly passed
 *              to external API calls without proper sanitization, potentially causing
 *              injection attacks or other vulnerabilities.
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
  UntrustedDataToExternalApiFlow::PathNode untrustedDataSource,  // Origin of potentially harmful data
  UntrustedDataToExternalApiFlow::PathNode apiCallTarget,         // Destination at the API invocation
  ExternalApiUsedWithUntrustedData vulnerableApiInvocation         // External API receiving tainted input
where
  // Ensure the target node matches the API's parameter that processes untrusted data
  apiCallTarget.getNode() = vulnerableApiInvocation.getUntrustedDataNode()
  and
  // Validate that a complete data flow path exists from source to destination
  UntrustedDataToExternalApiFlow::flowPath(untrustedDataSource, apiCallTarget)
select
  // Output format preserved with enhanced variable naming for clarity
  apiCallTarget.getNode(), untrustedDataSource, apiCallTarget,
  "External API call to " + vulnerableApiInvocation.toString() + " processes untrusted data originating from $@.", 
  untrustedDataSource.getNode(),
  untrustedDataSource.toString()