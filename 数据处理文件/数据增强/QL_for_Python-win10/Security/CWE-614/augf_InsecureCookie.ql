/**
 * @name Failure to use secure cookies
 * @description Insecure cookies may be transmitted in cleartext, making them vulnerable to
 *              interception attacks.
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

// Predicate to identify specific cookie security vulnerabilities
// Returns vulnerability type and severity index for each issue found
predicate identifiesSecurityIssue(Http::Server::CookieWrite cookie, string issueType, int severityIndex) {
  // Check for missing Secure flag (prevents HTTP transmission)
  cookie.hasSecureFlag(false) and
  issueType = "Secure" and
  severityIndex = 0
  or
  // Check for missing HttpOnly flag (prevents XSS access)
  cookie.hasHttpOnlyFlag(false) and
  issueType = "HttpOnly" and
  severityIndex = 1
  or
  // Check for unsafe SameSite=None setting (allows cross-site requests)
  cookie.hasSameSiteAttribute(any(Http::Server::CookieWrite::SameSiteNone v)) and
  issueType = "SameSite" and
  severityIndex = 2
}

// Predicate to generate consolidated security alert messages
// Combines multiple issues into appropriate warning text
predicate generatesAlertMessage(Http::Server::CookieWrite cookie, string alertMessage) {
  // Count total security issues found in cookie configuration
  exists(int issueCount | issueCount = strictcount(string issue | identifiesSecurityIssue(cookie, issue, _)) |
    // Handle single-issue case with simple attribute message
    issueCount = 1 and
    alertMessage = any(string issue | identifiesSecurityIssue(cookie, issue, _)) + " attribute"
    or
    // Handle dual-issue case with combined attribute message
    issueCount = 2 and
    alertMessage =
      strictconcat(string issue, int idx | 
        identifiesSecurityIssue(cookie, issue, idx) | 
        issue, " and " order by idx
      ) + " attributes"
    or
    // Handle triple-issue case with comprehensive message
    issueCount = 3 and
    alertMessage = "Secure, HttpOnly, and SameSite attributes"
  )
}

// Query to detect cookies with insecure configurations
// Generates warnings for each vulnerable cookie setting
from Http::Server::CookieWrite cookie, string alertMessage
where generatesAlertMessage(cookie, alertMessage)
select cookie, "Cookie is added without the " + alertMessage + " properly set."