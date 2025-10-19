/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description Exposing sensitive information without proper access control measures in place
 *              can lead to unauthorized disclosure of confidential data.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.1
 * @precision high
 * @id py/views-cwe-200
 * @tags security
 *       external/cwe/cwe-200
 */

// Import Python analysis library
import python

// Import specific view for detecting exposure vulnerabilities
import semmle.python.security.dataflow.ViewSecurityFlows

// Define path graph component for flow visualization
import ViewSecurityFlow::PathGraph

// Identify flow paths between source (untrusted input) and sink (exposure point)
from ViewSecurityFlow::PathNode taintedSource, ViewSecurityFlow::PathNode exposedSink

// Verify existence of complete data flow path
where ViewSecurityFlow::flowPath(taintedSource, exposedSink)

// Report exposure issue with detailed context
select exposedSink.getNode(),
       taintedSource,
       exposedSink,
       "Sensitive data exposure occurs at this location, derived from a $@.",
       taintedSource.getNode(),
       "user-controlled source"