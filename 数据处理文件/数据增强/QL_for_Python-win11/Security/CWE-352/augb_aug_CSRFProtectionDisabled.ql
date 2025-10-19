/**
 * @name CSRF protection weakened or disabled
 * @description Disabling or weakening CSRF protection may make the application
 *              vulnerable to a Cross-Site Request Forgery (CSRF) attack.
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

// Predicate to identify non-test CSRF protection configurations
// Filters out test files where CSRF protection is commonly disabled
// Uses path pattern matching to exclude test directories
predicate isProductionConfiguration(Http::Server::CsrfProtectionSetting csrfSetting) {
  not csrfSetting.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate to detect vulnerable CSRF configurations
// Identifies settings that create security risks by:
// 1. Having CSRF verification disabled
// 2. Lacking any local CSRF protection mechanisms
// 3. Being located in production code (not test files)
predicate hasInsufficientCsrfProtection(Http::Server::CsrfProtectionSetting csrfSetting) {
  csrfSetting.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localProtection | localProtection.csrfEnabled()) and
  isProductionConfiguration(csrfSetting)
}

// Main query to identify all vulnerable CSRF configurations
// Ensures comprehensive detection by verifying that all production
// configurations are vulnerable, eliminating false positives
from Http::Server::CsrfProtectionSetting csrfSetting
where
  // Current configuration must be vulnerable
  hasInsufficientCsrfProtection(csrfSetting) and
  // Ensure all non-test configurations are vulnerable
  not exists(Http::Server::CsrfProtectionSetting alternativeCsrfSetting |
    isProductionConfiguration(alternativeCsrfSetting) and
    not hasInsufficientCsrfProtection(alternativeCsrfSetting)
  )
select csrfSetting, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."