/**
 * @name Failure to use secure cookies
 * @description Detects cookies that lack proper security attributes,
 *              making them vulnerable to interception in cleartext.
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

// Predicate to identify specific security vulnerabilities in cookie configuration
predicate hasCookieSecurityIssue(Http::Server::CookieWrite cookieWrite, string vulnerabilityType, int vulnerabilityIndex) {
  // Detect missing Secure flag (index 0)
  cookieWrite.hasSecureFlag(false) and
  vulnerabilityType = "Secure" and
  vulnerabilityIndex = 0
  or
  // Detect missing HttpOnly flag (index 1)
  cookieWrite.hasHttpOnlyFlag(false) and
  vulnerabilityType = "HttpOnly" and
  vulnerabilityIndex = 1
  or
  // Detect SameSite=None setting (index 2)
  cookieWrite.hasSameSiteAttribute(any(Http::Server::CookieWrite::SameSiteNone v)) and
  vulnerabilityType = "SameSite" and
  vulnerabilityIndex = 2
}

// Predicate to generate appropriate security alert messages based on detected vulnerabilities
predicate generateSecurityAlert(Http::Server::CookieWrite cookieWrite, string securityAlert) {
  // Count the total number of security vulnerabilities found for this cookie
  exists(int vulnerabilityCount | 
    vulnerabilityCount = strictcount(string vulnType | hasCookieSecurityIssue(cookieWrite, vulnType, _)) |
    // Handle different scenarios based on vulnerability count
    (
      // Single vulnerability case
      vulnerabilityCount = 1 and
      securityAlert = any(string singleVuln | hasCookieSecurityIssue(cookieWrite, singleVuln, _)) + " attribute"
    )
    or
    (
      // Two vulnerabilities case
      vulnerabilityCount = 2 and
      securityAlert =
        strictconcat(string vulnType, int idx | 
          hasCookieSecurityIssue(cookieWrite, vulnType, idx) | 
          vulnType, 
          " and " 
          order by idx
        ) + " attributes"
    )
    or
    (
      // Three vulnerabilities case
      vulnerabilityCount = 3 and
      securityAlert = "Secure, HttpOnly, and SameSite attributes"
    )
  )
}

// Main query to identify cookies with security vulnerabilities and generate corresponding alerts
from Http::Server::CookieWrite cookieWrite, string securityAlert
where generateSecurityAlert(cookieWrite, securityAlert)
select cookieWrite, "Cookie is added without the " + securityAlert + " properly set."