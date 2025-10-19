/**
 * @name CSRF protection weakened or disabled
 * @description Applications with disabled or weakened CSRF protection are susceptible
 *              to Cross-Site Request Forgery (CSRF) attacks, allowing malicious actors
 *              to perform unauthorized actions on behalf of authenticated users.
 * @kind problem
 * @problem.severity warning
 * @security-severity 8.8
 * @precision high
 * @id py/csrf-protection-disabled
 * @tags security
 *       external/cwe/cwe-352
 */

import python
import semmle.python.Concepts

// Predicate to determine if a CSRF configuration is in production code
// This excludes test configurations to focus on code that affects the application's security
predicate isProductionCsrfConfiguration(Http::Server::CsrfProtectionSetting csrfProtectionSetting) {
  // Filter out test files by checking if the file path contains "test"
  not csrfProtectionSetting.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate to identify CSRF configurations that are vulnerable to attacks
// This checks if a configuration lacks proper protection mechanisms
predicate hasInsufficientCsrfProtection(Http::Server::CsrfProtectionSetting csrfProtectionSetting) {
  // A configuration is vulnerable if:
  // 1. CSRF verification is explicitly disabled
  // 2. No alternative local CSRF protection mechanism is active
  csrfProtectionSetting.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localCsrfProtection | localCsrfProtection.csrfEnabled())
}

// Main query that identifies CSRF vulnerabilities in the application
// This finds configurations that are both vulnerable and indicative of the app's security state
from Http::Server::CsrfProtectionSetting csrfProtectionSetting
where
  // The configuration must be in production code and vulnerable
  isProductionCsrfConfiguration(csrfProtectionSetting) and
  hasInsufficientCsrfProtection(csrfProtectionSetting) and
  // Ensure this is a legitimate security issue by verifying there are no
  // secure CSRF configurations in the production code
  not exists(Http::Server::CsrfProtectionSetting secureCsrfConfig |
    isProductionCsrfConfiguration(secureCsrfConfig) and
    not hasInsufficientCsrfProtection(secureCsrfConfig)
  )
select csrfProtectionSetting, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."