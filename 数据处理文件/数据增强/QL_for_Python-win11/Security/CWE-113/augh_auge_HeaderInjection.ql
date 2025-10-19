/**
 * @name HTTP Response Splitting
 * @description Directly writing user-controlled input to HTTP headers
 *              enables header splitting attacks through injection.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id py/http-response-splitting
 * @tags security
 *       external/cwe/cwe-113
 *       external/cwe/cwe-079
 */

// Import core Python analysis capabilities
import python

// Import specialized HTTP header injection flow analysis module
import semmle.python.security.dataflow.HttpHeaderInjectionQuery

// Import path graph representation for data flow visualization
import HeaderInjectionFlow::PathGraph

// Define data flow source and sink nodes representing tainted origins and vulnerable endpoints
from HeaderInjectionFlow::PathNode taintedSource, HeaderInjectionFlow::PathNode vulnerableSink

// Identify complete data flow paths where tainted input reaches HTTP header sinks
where HeaderInjectionFlow::flowPath(taintedSource, vulnerableSink)

// Report vulnerable header locations with taint source details and contextual warning
select vulnerableSink.getNode(), taintedSource, vulnerableSink, 
       "This HTTP header incorporates untrusted $@.", taintedSource.getNode(), 
       "user-controlled input"