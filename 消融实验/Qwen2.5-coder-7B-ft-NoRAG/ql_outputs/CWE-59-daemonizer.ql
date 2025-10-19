/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @description This query detects potential vulnerabilities related to improper link resolution before file access, which could lead to arbitrary file access.
 * @kind path-problem
 * @id py/link-resolution-before-file-access
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 */

import python
import experimental.Security.LinkResolutionBeforeFileAccessQuery
import LinkResolutionBeforeFileAccessFlow::PathGraph

from LinkResolutionBeforeFileAccessFlow::PathNode source, LinkResolutionBeforeFileAccessFlow::PathNode sink
where LinkResolutionBeforeFileAccessFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Potential vulnerability due to improper link resolution before file access.", source.getNode(), "source node"