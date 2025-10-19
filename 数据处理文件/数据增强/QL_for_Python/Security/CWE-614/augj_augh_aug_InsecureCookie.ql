/**
 * @name Failure to use secure cookies
 * @description Identifies cookies lacking proper security attributes that could
 *              lead to interception and manipulation through insecure transmission.
 * @kind problem
 * @problem.severity warning
 * @security-severity 5.0
 * @precision high
 * @id py/insecure-cookie
 * @tags security
 *       external/cwe/cwe-614
 *       external/cwe/cwe-1004
 *       external/cwe/cwe-1275
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.Concepts

// Evaluates cookie security posture by identifying missing critical security attributes
// Maps each identified weakness to its type and relative severity level
predicate hasSecurityDefect(Http::Server::CookieWrite cookie, string defectType, int severityLevel) {
  // Detects cookies without Secure flag (exposes to MITM attacks over HTTP)
  cookie.hasSecureFlag(false) and
  defectType = "Secure" and
  severityLevel = 0
  or
  // Detects cookies without HttpOnly flag (vulnerable to XSS attacks)
  cookie.hasHttpOnlyFlag(false) and
  defectType = "HttpOnly" and
  severityLevel = 1
  or
  // Detects cookies with SameSite=None (increases CSRF attack surface)
  cookie.hasSameSiteAttribute(any(Http::Server::CookieWrite::SameSiteNone v)) and
  defectType = "SameSite" and
  severityLevel = 2
}

// Generates contextual security alerts based on identified cookie vulnerabilities
// Formats warning messages according to the number and combination of defects
predicate generateSecurityAlert(Http::Server::CookieWrite cookie, string alertMessage) {
  // Calculate total security weaknesses in the cookie configuration
  exists(int flawCount | 
    flawCount = strictcount(string flawType | hasSecurityDefect(cookie, flawType, _)) |
    // Single vulnerability scenario
    flawCount = 1 and
    alertMessage = any(string flawType | hasSecurityDefect(cookie, flawType, _)) + " attribute"
    or
    // Dual vulnerability scenario with ordered concatenation
    flawCount = 2 and
    alertMessage =
      strictconcat(string flawType, int severityIndex | 
        hasSecurityDefect(cookie, flawType, severityIndex) | 
        flawType, " and " order by severityIndex
      ) + " attributes"
    or
    // Triple vulnerability scenario (all critical attributes missing)
    flawCount = 3 and
    alertMessage = "Secure, HttpOnly, and SameSite attributes"
  )
}

// Primary detection logic: identifies cookies with security misconfigurations
// Generates standardized vulnerability warnings for each affected cookie
from Http::Server::CookieWrite cookie, string alertMessage
where generateSecurityAlert(cookie, alertMessage)
select cookie, "Cookie is added without the " + alertMessage + " properly set."