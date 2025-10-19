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

// Predicate to identify CSRF protection settings in production environments
// Filters out configurations located in test files where CSRF protection is typically disabled
predicate isProductionCsrfSetting(Http::Server::CsrfProtectionSetting csrfProtectionSetting) {
  not csrfProtectionSetting.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate to detect insecure CSRF configurations
// Checks if verification is disabled and no local CSRF protection is enabled
predicate hasVulnerableCsrfConfig(Http::Server::CsrfProtectionSetting csrfProtectionSetting) {
  csrfProtectionSetting.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localCsrfProtection | localCsrfProtection.csrfEnabled()) and
  isProductionCsrfSetting(csrfProtectionSetting)
}

// Main query to identify CSRF vulnerabilities in production settings
// Ensures all production configurations consistently exhibit the same vulnerability
from Http::Server::CsrfProtectionSetting csrfProtectionSetting
where
  hasVulnerableCsrfConfig(csrfProtectionSetting) and
  // Verify that all production settings share the same vulnerable state
  forall(Http::Server::CsrfProtectionSetting additionalCsrfSetting | 
         isProductionCsrfSetting(additionalCsrfSetting) | 
         hasVulnerableCsrfConfig(additionalCsrfSetting))
select csrfProtectionSetting, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."