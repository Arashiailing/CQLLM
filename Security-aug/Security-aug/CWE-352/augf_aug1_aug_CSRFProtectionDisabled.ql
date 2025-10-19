/**
 * @name CSRF protection weakened or disabled
 * @description Detects applications where CSRF protection has been disabled or weakened,
 *              leaving them vulnerable to Cross-Site Request Forgery attacks.
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

// Predicate to exclude test-related CSRF configurations from analysis
predicate isNonTestConfiguration(Http::Server::CsrfProtectionSetting csrfConfig) {
  // Filter out configurations in test files to prevent false positives
  not csrfConfig.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate to identify CSRF configurations with inadequate protection
predicate hasInsufficientCsrfProtection(Http::Server::CsrfProtectionSetting csrfConfig) {
  // A configuration is considered vulnerable when:
  // 1. CSRF verification is explicitly disabled
  // 2. No alternative local CSRF protection is active
  // 3. The configuration is not part of test code
  csrfConfig.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localCsrfProtection | localCsrfProtection.csrfEnabled()) and
  isNonTestConfiguration(csrfConfig)
}

// Predicate to validate that all non-test configurations are vulnerable
predicate allNonTestConfigsAreVulnerable() {
  // Ensure no secure non-test configurations exist in the codebase
  not exists(Http::Server::CsrfProtectionSetting alternativeConfig |
    isNonTestConfiguration(alternativeConfig) and
    not hasInsufficientCsrfProtection(alternativeConfig)
  )
}

// Main query logic for identifying CSRF vulnerabilities
from Http::Server::CsrfProtectionSetting csrfConfig
where
  // Configuration must have insufficient CSRF protection
  hasInsufficientCsrfProtection(csrfConfig) and
  // Verify no secure non-test configurations exist (reduces false positives)
  allNonTestConfigsAreVulnerable()
select csrfConfig, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."