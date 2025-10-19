/**
 * @name HTTP Response Splitting
 * @description Detects unsafe HTTP header construction where user input
 *              is directly written to headers, enabling header splitting attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id py/http-response-splitting
 * @tags security
 *       external/cwe/cwe-113
 *       external/cwe/cwe-079
 */

// Core Python language analysis module
import python

// HTTP header injection vulnerability detection module
import semmle.python.security.dataflow.HttpHeaderInjectionQuery

// Path graph representation for data flow analysis
import HeaderInjectionFlow::PathGraph

// Identify vulnerable HTTP header flows
from 
  // Source node representing untrusted user input
  HeaderInjectionFlow::PathNode untrustedInput, 
  // Sink node representing HTTP header construction
  HeaderInjectionFlow::PathNode headerSink

// Verify data flow from untrusted input to header sink
where 
  HeaderInjectionFlow::flowPath(untrustedInput, headerSink)

// Report vulnerability with flow path details
select 
  // Vulnerable header location
  headerSink.getNode(), 
  // Data flow source
  untrustedInput, 
  // Data flow sink
  headerSink, 
  // Vulnerability description
  "This HTTP header is constructed from a $@.", 
  // Source element reference
  untrustedInput.getNode(), 
  // Source element description
  "user-provided value"