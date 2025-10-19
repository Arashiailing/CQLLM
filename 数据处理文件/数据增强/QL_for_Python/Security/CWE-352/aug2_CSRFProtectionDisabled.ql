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

// Predicate to identify CSRF protection settings outside test environments
// Excludes test files where CSRF protection is commonly disabled
predicate isProductionCsrfSetting(Http::Server::CsrfProtectionSetting csrfConfig) {
  not csrfConfig.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate to detect vulnerable CSRF configurations
// Identifies settings where verification is disabled and no local protection exists
predicate hasVulnerableCsrfConfig(Http::Server::CsrfProtectionSetting csrfConfig) {
  csrfConfig.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localProtection | localProtection.csrfEnabled()) and
  isProductionCsrfSetting(csrfConfig)
}

// Main query finding CSRF vulnerabilities in production configurations
// Ensures all relevant settings are consistently vulnerable
from Http::Server::CsrfProtectionSetting csrfConfig
where
  hasVulnerableCsrfConfig(csrfConfig) and
  // Validate all production settings share the same vulnerability state
  forall(Http::Server::CsrfProtectionSetting otherConfig | 
         isProductionCsrfSetting(otherConfig) | 
         hasVulnerableCsrfConfig(otherConfig))
select csrfConfig, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."