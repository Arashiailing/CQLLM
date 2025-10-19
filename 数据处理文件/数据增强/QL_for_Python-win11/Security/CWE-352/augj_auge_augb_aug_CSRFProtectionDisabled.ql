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

// Identifies production environment CSRF configurations
// Filters out test-related files using path pattern analysis
predicate isProductionCsrfConfig(Http::Server::CsrfProtectionSetting csrfSetting) {
  not csrfSetting.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Detects configurations with insufficient CSRF protection
// Evaluates three critical conditions:
// 1. CSRF verification is disabled
// 2. No local CSRF protection mechanisms exist
// 3. Configuration applies to production environment
predicate isCsrfProtectionInadequate(Http::Server::CsrfProtectionSetting csrfSetting) {
  csrfSetting.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localProtection | 
    localProtection.csrfEnabled()
  ) and
  isProductionCsrfConfig(csrfSetting)
}

// Primary query to identify vulnerable CSRF configurations
// Performs comprehensive analysis by:
// 1. Confirming current configuration has inadequate protection
// 2. Ensuring no secure configurations exist in production
from Http::Server::CsrfProtectionSetting vulnerableConfig
where
  // Current configuration must be vulnerable
  isCsrfProtectionInadequate(vulnerableConfig) and
  // Production environment must lack secure alternatives
  not exists(Http::Server::CsrfProtectionSetting secureConfig |
    isProductionCsrfConfig(secureConfig) and
    not isCsrfProtectionInadequate(secureConfig)
  )
select vulnerableConfig, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."