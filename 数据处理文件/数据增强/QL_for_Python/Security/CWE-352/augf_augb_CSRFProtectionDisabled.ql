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

// Identify CSRF configurations from production environments (excluding test files)
predicate isProductionCsrfConfig(Http::Server::CsrfProtectionSetting csrfSetting) {
  // Exclude test files (paths containing "test") where CSRF protection is typically disabled
  not csrfSetting.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Detect CSRF configurations that are vulnerable to attacks
predicate isVulnerableToCsrf(Http::Server::CsrfProtectionSetting csrfSetting) {
  // A configuration is vulnerable if CSRF verification is disabled and no local protection is enabled
  csrfSetting.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localProtection | 
             localProtection.csrfEnabled()) and
  isProductionCsrfConfig(csrfSetting)
}

// Find all vulnerable CSRF configurations in production environments
from Http::Server::CsrfProtectionSetting vulnerableCsrfConfig
where
  // The configuration must be vulnerable
  isVulnerableToCsrf(vulnerableCsrfConfig) and
  // Ensure we're not reporting false positives from virtual projects by verifying
  // that all production CSRF configurations are vulnerable
  forall(Http::Server::CsrfProtectionSetting productionConfig | 
         isProductionCsrfConfig(productionConfig) | 
         isVulnerableToCsrf(productionConfig))
select vulnerableCsrfConfig, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."