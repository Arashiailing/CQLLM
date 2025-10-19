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

// Predicate to filter out test-related CSRF configurations
predicate isNonTestConfiguration(Http::Server::CsrfProtectionSetting csrfSetting) {
  // Exclude configurations located in test-related files
  // Path-based filtering ensures comprehensive test coverage exclusion
  not csrfSetting.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate to identify configurations with insufficient CSRF protection
predicate hasInsufficientCsrfProtection(Http::Server::CsrfProtectionSetting csrfSetting) {
  // A configuration is vulnerable when:
  // 1. CSRF verification is explicitly disabled
  // 2. No alternative local CSRF protection mechanism is active
  // 3. The configuration is not part of test code
  csrfSetting.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localProtection | localProtection.csrfEnabled()) and
  isNonTestConfiguration(csrfSetting)
}

// Predicate to confirm all non-test configurations are vulnerable (reduces false positives)
predicate allNonTestConfigsAreVulnerable() {
  not exists(Http::Server::CsrfProtectionSetting alternativeSetting |
    isNonTestConfiguration(alternativeSetting) and
    not hasInsufficientCsrfProtection(alternativeSetting)
  )
}

// Main query identifying CSRF vulnerabilities
from Http::Server::CsrfProtectionSetting csrfSetting
where
  // Configuration must have insufficient CSRF protection
  hasInsufficientCsrfProtection(csrfSetting) and
  // Verify no secure non-test configurations exist (eliminates false positives)
  allNonTestConfigsAreVulnerable()
select csrfSetting, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."