/**
 * @name Untrusted data passed to external API
 * @description Detects untrusted remote data flowing to external APIs without sanitization
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
  UntrustedDataToExternalApiFlow::PathNode untrustedSource,
  UntrustedDataToExternalApiFlow::PathNode vulnerableSink,
  ExternalApiUsedWithUntrustedData riskyExternalApi
where
  vulnerableSink.getNode() = riskyExternalApi.getUntrustedDataNode() and
  UntrustedDataToExternalApiFlow::flowPath(untrustedSource, vulnerableSink)
select
  vulnerableSink.getNode(), untrustedSource, vulnerableSink,
  "Call to " + riskyExternalApi.toString() + " with untrusted data from $@.", untrustedSource.getNode(),
  untrustedSource.toString()