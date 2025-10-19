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

// Predicate to identify production CSRF configurations
// Excludes test files using path pattern matching
predicate isProductionConfig(Http::Server::CsrfProtectionSetting csrfConfig) {
  not csrfConfig.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate to detect vulnerable CSRF configurations
// Checks for:
// 1. Disabled CSRF verification
// 2. Absence of local CSRF protection
// 3. Production environment context
predicate hasVulnerableCsrfConfig(Http::Server::CsrfProtectionSetting csrfConfig) {
  csrfConfig.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localCsrfSetting | 
    localCsrfSetting.csrfEnabled()
  ) and
  isProductionConfig(csrfConfig)
}

// Main query identifying vulnerable CSRF configurations
// Ensures comprehensive detection by:
// 1. Verifying current configuration vulnerability
// 2. Confirming all production configurations are vulnerable
from Http::Server::CsrfProtectionSetting csrfConfig
where
  // Current configuration must be vulnerable
  hasVulnerableCsrfConfig(csrfConfig) and
  // No alternative secure configurations exist in production
  not exists(Http::Server::CsrfProtectionSetting otherCsrfConfig |
    isProductionConfig(otherCsrfConfig) and
    not hasVulnerableCsrfConfig(otherCsrfConfig)
  )
select csrfConfig, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."