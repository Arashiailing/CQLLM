/**
 * @name Untrusted data passed to external API
 * @description Detects when untrusted remote data flows to external APIs without sanitization
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
  UntrustedDataToExternalApiFlow::PathNode untrustedDataSource,
  UntrustedDataToExternalApiFlow::PathNode vulnerableApiSink,
  ExternalApiUsedWithUntrustedData externalApiWithUntrustedData
where
  // Establish sink connection to external API
  vulnerableApiSink.getNode() = externalApiWithUntrustedData.getUntrustedDataNode()
  and
  // Verify data flow from untrusted source to vulnerable sink
  UntrustedDataToExternalApiFlow::flowPath(untrustedDataSource, vulnerableApiSink)
select
  vulnerableApiSink.getNode(), 
  untrustedDataSource, 
  vulnerableApiSink,
  "Call to " + externalApiWithUntrustedData.toString() + " with untrusted data from $@.", 
  untrustedDataSource.getNode(),
  untrustedDataSource.toString()