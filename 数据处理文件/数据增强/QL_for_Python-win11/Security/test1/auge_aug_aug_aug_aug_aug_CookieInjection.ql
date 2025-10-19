/**
 * @name Cookie Injection via Untrusted Data Sources
 * @description Detects potential cookie poisoning vulnerabilities by tracking data flows
 *              from untrusted sources to cookie construction operations. Identifies when
 *              unsanitized user input is used to create HTTP cookies.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

import python
import semmle.python.security.dataflow.CookieInjectionQuery
import CookieInjectionFlow::PathGraph

/** 
 * Core vulnerability detection logic:
 * - Tracks data flow from untrusted sources (e.g., user inputs)
 * - Identifies cookie creation operations as potential sinks
 * - Reports paths where untrusted data reaches cookie construction points
 */
from 
  CookieInjectionFlow::PathNode taintedSource,
  CookieInjectionFlow::PathNode cookieCreationSink
where 
  // Verify data flows from untrusted source to cookie sink
  CookieInjectionFlow::flowPath(taintedSource, cookieCreationSink)

// Output format maintains original structure with enhanced variable names:
select 
  cookieCreationSink.getNode(),
  taintedSource,
  cookieCreationSink,
  "Cookie is built using $@.",
  taintedSource.getNode(),
  "untrusted user input"