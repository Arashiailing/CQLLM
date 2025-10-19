/**
 * @name Cookie Poisoning via Untrusted Input
 * @description Detects cookie creation using untrusted data sources, which can lead to Cookie Poisoning vulnerabilities
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import core Python analysis framework
import python

// Import security analysis module for Cookie injection vulnerabilities
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path graph module for visualizing data flow paths
import CookieInjectionFlow::PathGraph

// Define data flow analysis components
from 
  CookieInjectionFlow::PathNode taintedSource, 
  CookieInjectionFlow::PathNode cookieSink
where 
  // Establish complete data flow path from untrusted source to cookie sink
  exists(CookieInjectionFlow::PathNode intermediateNode | 
    CookieInjectionFlow::flowPath(taintedSource, intermediateNode) and 
    CookieInjectionFlow::flowPath(intermediateNode, cookieSink)
  )
// Generate vulnerability report with sink, source, path, and description
select 
  cookieSink.getNode(), 
  taintedSource, 
  cookieSink, 
  "Cookie is built using $@.", 
  taintedSource.getNode(), 
  "untrusted user input"