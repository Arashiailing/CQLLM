/**
 * @name CSRF protection weakened or disabled
 * @description Detects applications that are susceptible to Cross-Site Request Forgery (CSRF) attacks
 *              because their CSRF protection mechanisms have been turned off or are not properly implemented.
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

// Predicate to identify CSRF configurations in production environments (excluding test files)
predicate isProductionCsrfConfig(Http::Server::CsrfProtectionSetting csrfConfig) {
  not csrfConfig.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate to identify CSRF configurations that lack proper protection mechanisms
predicate hasInsufficientCsrfProtection(Http::Server::CsrfProtectionSetting csrfConfig) {
  csrfConfig.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localProtection | 
             localProtection.csrfEnabled())
}

// Main query to locate CSRF vulnerabilities in production environments
// This ensures that all production CSRF configurations are consistently checked for vulnerabilities
from Http::Server::CsrfProtectionSetting csrfConfig
where
  isProductionCsrfConfig(csrfConfig) and
  hasInsufficientCsrfProtection(csrfConfig) and
  // Confirm that all production CSRF settings have the same vulnerable state
  forall(Http::Server::CsrfProtectionSetting otherCsrfConfig | 
         isProductionCsrfConfig(otherCsrfConfig) | 
         hasInsufficientCsrfProtection(otherCsrfConfig))
select csrfConfig, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."