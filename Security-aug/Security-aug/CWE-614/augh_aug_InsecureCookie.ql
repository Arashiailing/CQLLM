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

// Evaluates cookie configuration for security weaknesses
// Returns vulnerability type and severity ranking for each identified issue
predicate hasSecurityDefect(Http::Server::CookieWrite cookie, string vulnerabilityType, int severityRanking) {
  // Flags cookies missing Secure attribute (required for HTTPS-only transmission)
  cookie.hasSecureFlag(false) and
  vulnerabilityType = "Secure" and
  severityRanking = 0
  or
  // Flags cookies missing HttpOnly attribute (prevents client-side script access)
  cookie.hasHttpOnlyFlag(false) and
  vulnerabilityType = "HttpOnly" and
  severityRanking = 1
  or
  // Flags cookies with SameSite=None setting (potentially vulnerable to CSRF)
  cookie.hasSameSiteAttribute(any(Http::Server::CookieWrite::SameSiteNone v)) and
  vulnerabilityType = "SameSite" and
  severityRanking = 2
}

// Constructs contextual security warning messages based on detected vulnerabilities
predicate generateSecurityAlert(Http::Server::CookieWrite cookie, string securityWarning) {
  // Calculate total number of security vulnerabilities present in cookie
  exists(int vulnerabilityCount | 
    vulnerabilityCount = strictcount(string vulnType | hasSecurityDefect(cookie, vulnType, _)) |
    // Format warning message according to vulnerability count
    vulnerabilityCount = 1 and
    securityWarning = any(string vulnType | hasSecurityDefect(cookie, vulnType, _)) + " attribute"
    or
    vulnerabilityCount = 2 and
    securityWarning =
      strictconcat(string vulnType, int rankIndex | 
        hasSecurityDefect(cookie, vulnType, rankIndex) | 
        vulnType, " and " order by rankIndex
      ) + " attributes"
    or
    vulnerabilityCount = 3 and
    securityWarning = "Secure, HttpOnly, and SameSite attributes"
  )
}

// Main query: identifies cookies with security vulnerabilities and generates warnings
from Http::Server::CookieWrite cookie, string securityWarning
where generateSecurityAlert(cookie, securityWarning)
select cookie, "Cookie is added without the " + securityWarning + " properly set."