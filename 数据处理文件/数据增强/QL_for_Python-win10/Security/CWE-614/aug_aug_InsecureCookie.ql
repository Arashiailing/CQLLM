/**
 * @name Insecure Cookie Configuration Detection
 * @description Detects cookies that lack proper security settings, which could lead to
 *              sensitive data being transmitted over unencrypted channels or exposed
 *              to client-side script access.
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

// Identifies cookie security vulnerabilities by checking various security attributes
predicate identifyCookieVulnerability(Http::Server::CookieWrite cookieInstance, string vulnerabilityType, int severityRanking) {
  // Detects when Secure flag is not enabled
  cookieInstance.hasSecureFlag(false) and
  vulnerabilityType = "Secure" and
  severityRanking = 0
  or
  // Detects when HttpOnly flag is not enabled
  cookieInstance.hasHttpOnlyFlag(false) and
  vulnerabilityType = "HttpOnly" and
  severityRanking = 1
  or
  // Detects when SameSite is set to None, which may be insecure
  cookieInstance.hasSameSiteAttribute(any(Http::Server::CookieWrite::SameSiteNone v)) and
  vulnerabilityType = "SameSite" and
  severityRanking = 2
}

// Creates appropriate alert messages based on identified vulnerabilities
predicate createAlertMessage(Http::Server::CookieWrite cookieInstance, string securityWarning) {
  // Count the total number of security vulnerabilities in the cookie
  exists(int vulnerabilityCount | 
    vulnerabilityCount = strictcount(string vulnerability | identifyCookieVulnerability(cookieInstance, vulnerability, _)) |
    // Generate different message formats based on vulnerability count
    vulnerabilityCount = 1 and
    securityWarning = any(string v | identifyCookieVulnerability(cookieInstance, v, _)) + " attribute"
    or
    vulnerabilityCount = 2 and
    securityWarning =
      strictconcat(string v, int idx | 
        identifyCookieVulnerability(cookieInstance, v, idx) | 
        v, " and " order by idx
      ) + " attributes"
    or
    vulnerabilityCount = 3 and
    securityWarning = "Secure, HttpOnly, and SameSite attributes"
  )
}

// Main query to find cookies with security vulnerabilities and generate alerts
from Http::Server::CookieWrite cookieInstance, string securityWarning
where createAlertMessage(cookieInstance, securityWarning)
select cookieInstance, "Cookie is added without the " + securityWarning + " properly set."