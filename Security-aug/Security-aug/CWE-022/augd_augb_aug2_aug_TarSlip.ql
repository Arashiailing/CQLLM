/**
 * @name Arbitrary file write during tarfile extraction
 * @description This query identifies potential directory traversal vulnerabilities
 *              that occur when extracting tar archives without proper path validation.
 *              Attackers can exploit this to write files outside the intended directory.
 * @kind path-problem
 * @id py/tarslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @tags security
 *       external/cwe/cwe-022
 */

import python
import semmle.python.security.dataflow.TarSlipQuery
import TarSlipFlow::PathGraph

// Define data flow sources and sinks for tar extraction vulnerability
from TarSlipFlow::PathNode untrustedDataSource, TarSlipFlow::PathNode extractionTarget

// Check if there's a data flow path from untrusted source to extraction target
where TarSlipFlow::flowPath(untrustedDataSource, extractionTarget)

// Report the vulnerability with appropriate context
select extractionTarget.getNode(), 
       untrustedDataSource, 
       extractionTarget, 
       "This file extraction depends on a $@.", 
       untrustedDataSource.getNode(),
       "potentially uncontrolled input source"