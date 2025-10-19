/**
 * @name Insecure Cookie Configuration Detection
 * @description Identifies cookies lacking essential security attributes, potentially exposing 
 *              sensitive data to unencrypted transmission or client-side script access.
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

// Evaluates cookie security posture by checking critical protection mechanisms
predicate evaluateCookieSecurity(Http::Server::CookieWrite cookieConfig, string weaknessType, int riskLevel) {
  // Check for missing Secure flag protection
  cookieConfig.hasSecureFlag(false) and
  weaknessType = "Secure" and
  riskLevel = 0
  or
  // Check for missing HttpOnly flag protection
  cookieConfig.hasHttpOnlyFlag(false) and
  weaknessType = "HttpOnly" and
  riskLevel = 1
  or
  // Check for potentially unsafe SameSite=None configuration
  cookieConfig.hasSameSiteAttribute(any(Http::Server::CookieWrite::SameSiteNone v)) and
  weaknessType = "SameSite" and
  riskLevel = 2
}

// Generates contextual security alerts based on detected weaknesses
predicate generateSecurityAlert(Http::Server::CookieWrite cookieConfig, string alertText) {
  // Aggregate and categorize identified security weaknesses
  exists(int weaknessCount | 
    weaknessCount = strictcount(string weakness | evaluateCookieSecurity(cookieConfig, weakness, _)) |
    // Format alert messages based on weakness count
    weaknessCount = 1 and
    alertText = any(string w | evaluateCookieSecurity(cookieConfig, w, _)) + " attribute"
    or
    weaknessCount = 2 and
    alertText =
      strictconcat(string w, int idx | 
        evaluateCookieSecurity(cookieConfig, w, idx) | 
        w, " and " order by idx
      ) + " attributes"
    or
    weaknessCount = 3 and
    alertText = "Secure, HttpOnly, and SameSite attributes"
  )
}

// Primary detection logic for insecure cookie configurations
from Http::Server::CookieWrite cookieConfig, string alertText
where generateSecurityAlert(cookieConfig, alertText)
select cookieConfig, "Cookie is added without the " + alertText + " properly set."