/**
 * @name CSRF protection weakened or disabled
 * @description Applications with disabled or weakened CSRF protection are susceptible
 *              to Cross-Site Request Forgery (CSRF) attacks.
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

// Filter out test configurations by examining file paths
// Excludes any file containing "test" in its path
predicate isProductionCode(Http::Server::CsrfProtectionSetting csrfSetting) {
  not csrfSetting.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Identify configurations vulnerable to CSRF attacks:
// 1. CSRF verification is turned off
// 2. No local CSRF protection mechanisms are active
// 3. The configuration is in production code (not test code)
predicate hasCsrfVulnerability(Http::Server::CsrfProtectionSetting csrfSetting) {
  csrfSetting.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localCsrfGuard | localCsrfGuard.csrfEnabled()) and
  isProductionCode(csrfSetting)
}

// Primary detection logic for vulnerable CSRF configurations
// This query ensures comprehensive coverage by verifying that all
// production configurations are vulnerable, minimizing false positives
from Http::Server::CsrfProtectionSetting csrfSetting
where
  // The configuration must be vulnerable to CSRF
  hasCsrfVulnerability(csrfSetting) and
  // Confirm all production configurations are vulnerable
  not exists(Http::Server::CsrfProtectionSetting secureSetting |
    isProductionCode(secureSetting) and
    not hasCsrfVulnerability(secureSetting)
  )
select csrfSetting, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."