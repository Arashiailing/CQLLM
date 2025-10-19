/**
 * @name Cookie Injection via Untrusted Data Sources
 * @description Identifies potential cookie poisoning vulnerabilities by monitoring data flows
 *              from untrusted sources to cookie construction operations. Detects instances
 *              where unsanitized user input is utilized in HTTP cookie creation.
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
 * Main vulnerability detection mechanism:
 * - Monitors data propagation from untrusted origins (e.g., user inputs)
 * - Pinpoints cookie creation operations as potential vulnerability points
 * - Highlights paths where untrusted data flows into cookie construction
 */
from 
  CookieInjectionFlow::PathNode untrustedOrigin,
  CookieInjectionFlow::PathNode cookieGenerationSink
where 
  // Establish data flow connection between untrusted source and cookie sink
  CookieInjectionFlow::flowPath(untrustedOrigin, cookieGenerationSink)

// Report findings with enhanced variable naming while preserving output format:
select 
  cookieGenerationSink.getNode(),
  untrustedOrigin,
  cookieGenerationSink,
  "Cookie is constructed using $@.",
  untrustedOrigin.getNode(),
  "untrusted user input"