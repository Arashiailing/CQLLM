/**
 * @name Cookie Injection via Untrusted Data Sources
 * @description Detects cookie poisoning vulnerabilities by tracking data flows from untrusted sources to cookie construction operations.
 *              Identifies when application code uses unsanitized user input to create HTTP cookies.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Core Python analysis libraries
import python

// Security analysis module for cookie injection detection
import semmle.python.security.dataflow.CookieInjectionQuery

// Path visualization module for data flow tracking
import CookieInjectionFlow::PathGraph

/**
 * Vulnerability detection logic:
 * - Identify untrusted data sources (user inputs)
 * - Trace data flow through application components
 * - Detect cookie creation operations as sinks
 * - Report paths where untrusted data reaches cookie creation
 */
from 
  CookieInjectionFlow::PathNode untrustedSource,
  CookieInjectionFlow::PathNode cookieSink
where 
  // Validate data flow path from source to sink
  CookieInjectionFlow::flowPath(untrustedSource, cookieSink)

// Report findings with enhanced readability:
// [sink_location] [source_node] [sink_node] "Vulnerability description" [source_location] [input_type]
select 
  cookieSink.getNode(),
  untrustedSource,
  cookieSink,
  "Cookie is constructed using $@.",
  untrustedSource.getNode(),
  "untrusted user input"