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
// Filters out test files where CSRF protection is typically disabled for testing purposes
predicate isProductionCsrfConfig(Http::Server::CsrfProtectionSetting csrfSetting) {
  not csrfSetting.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate to detect CSRF configurations vulnerable to forgery attacks
// A configuration is vulnerable if verification is disabled and no local protection is active
predicate isCsrfVulnerable(Http::Server::CsrfProtectionSetting csrfSetting) {
  csrfSetting.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localProtection | localProtection.csrfEnabled()) and
  isProductionCsrfConfig(csrfSetting)
}

// Main query to find CSRF vulnerabilities in production configurations
// Ensures all relevant production settings consistently exhibit the same vulnerability
from Http::Server::CsrfProtectionSetting csrfSetting
where
  isCsrfVulnerable(csrfSetting) and
  // Validate that all production settings share the same vulnerability state
  forall(Http::Server::CsrfProtectionSetting otherSetting | 
         isProductionCsrfConfig(otherSetting) | 
         isCsrfVulnerable(otherSetting))
select csrfSetting, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."