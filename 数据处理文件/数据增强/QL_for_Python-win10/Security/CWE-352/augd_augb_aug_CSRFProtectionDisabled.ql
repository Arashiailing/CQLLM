/**
 * @name CSRF protection weakened or disabled
 * @description Disabling or weakening CSRF protection may expose the application
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

// Identify production CSRF configurations by excluding test files
// Uses path pattern matching to filter test directories
predicate isProductionConfig(Http::Server::CsrfProtectionSetting csrfConfig) {
  not csrfConfig.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Detect vulnerable CSRF configurations where:
// 1. Verification is disabled
// 2. No local CSRF protection exists
// 3. Configuration is in production code
predicate isVulnerableCsrfConfig(Http::Server::CsrfProtectionSetting csrfConfig) {
  csrfConfig.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localProtection | localProtection.csrfEnabled()) and
  isProductionConfig(csrfConfig)
}

// Main query identifying all vulnerable CSRF configurations
// Ensures comprehensive detection by verifying that all production
// configurations are vulnerable, eliminating false positives
from Http::Server::CsrfProtectionSetting csrfConfig
where
  // Configuration must be vulnerable
  isVulnerableCsrfConfig(csrfConfig) and
  // Ensure all production configurations are vulnerable
  not exists(Http::Server::CsrfProtectionSetting safeConfig |
    isProductionConfig(safeConfig) and
    not isVulnerableCsrfConfig(safeConfig)
  )
select csrfConfig, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."