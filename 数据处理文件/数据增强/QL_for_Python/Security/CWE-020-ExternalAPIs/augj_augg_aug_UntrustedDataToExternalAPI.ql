/**
 * @name Untrusted data passed to external API
 * @description Detects security issues where untrusted remote input is directly passed to external API functions without adequate sanitization.
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
  UntrustedDataToExternalApiFlow::PathNode taintedSource,        // Origin of the tainted data
  UntrustedDataToExternalApiFlow::PathNode taintedSink,           // Endpoint where tainted data is used
  ExternalApiUsedWithUntrustedData riskyApiCall                  // External API that processes the tainted data
where
  // Establish connection between sink node and API parameter
  taintedSink.getNode() = riskyApiCall.getUntrustedDataNode()
  and
  // Verify complete data flow path exists from source to sink
  UntrustedDataToExternalApiFlow::flowPath(taintedSource, taintedSink)
select
  // Maintain original output structure with enhanced naming
  taintedSink.getNode(), taintedSource, taintedSink,
  "Call to " + riskyApiCall.toString() + " with untrusted data from $@.", taintedSource.getNode(),
  taintedSource.toString()