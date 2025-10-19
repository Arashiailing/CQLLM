/**
 * @name Failure to use secure cookies
 * @description Identifies cookies configured without proper security attributes,
 *              which could lead to interception in plaintext.
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

// Predicate to determine if a cookie has specific security configuration flaws
predicate detectsCookieSecurityFlaw(Http::Server::CookieWrite cookieWrite, string flawCategory, int flawIdentifier) {
  // Check for missing Secure flag (identifier 0)
  cookieWrite.hasSecureFlag(false) and
  flawCategory = "Secure" and
  flawIdentifier = 0
  or
  // Check for missing HttpOnly flag (identifier 1)
  cookieWrite.hasHttpOnlyFlag(false) and
  flawCategory = "HttpOnly" and
  flawIdentifier = 1
  or
  // Check for SameSite=None setting (identifier 2)
  cookieWrite.hasSameSiteAttribute(any(Http::Server::CookieWrite::SameSiteNone v)) and
  flawCategory = "SameSite" and
  flawIdentifier = 2
}

// Predicate to create appropriate warning messages based on identified cookie security flaws
predicate composeSecurityWarning(Http::Server::CookieWrite cookieWrite, string warningMessage) {
  // Calculate the total number of security flaws for this cookie
  exists(int flawCount | 
    flawCount = strictcount(string flawType | detectsCookieSecurityFlaw(cookieWrite, flawType, _)) |
    // Handle different scenarios based on the number of flaws
    (
      // Single flaw scenario
      flawCount = 1 and
      warningMessage = any(string singleFlaw | detectsCookieSecurityFlaw(cookieWrite, singleFlaw, _)) + " attribute"
    )
    or
    (
      // Two flaws scenario
      flawCount = 2 and
      warningMessage =
        strictconcat(string flawType, int identifier | 
          detectsCookieSecurityFlaw(cookieWrite, flawType, identifier) | 
          flawType, 
          " and " 
          order by identifier
        ) + " attributes"
    )
    or
    (
      // Three flaws scenario
      flawCount = 3 and
      warningMessage = "Secure, HttpOnly, and SameSite attributes"
    )
  )
}

// Main query to find cookies with security configuration issues and generate corresponding warnings
from Http::Server::CookieWrite cookieWrite, string warningMessage
where composeSecurityWarning(cookieWrite, warningMessage)
select cookieWrite, "Cookie is added without the " + warningMessage + " properly set."