/**
 * @name CSRF protection weakened or disabled
 * @description Identifies applications vulnerable to Cross-Site Request Forgery (CSRF) attacks
 *              due to disabled or insufficient CSRF protection mechanisms.
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

// Filter out CSRF configurations in test environments where security is often relaxed
predicate isProductionCsrfConfig(Http::Server::CsrfProtectionSetting csrfProtectionSetting) {
  not csrfProtectionSetting.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Identify CSRF configurations that lack proper protection mechanisms
predicate hasInsufficientCsrfProtection(Http::Server::CsrfProtectionSetting csrfProtectionSetting) {
  csrfProtectionSetting.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localCsrfProtection | 
             localCsrfProtection.csrfEnabled()) and
  isProductionCsrfConfig(csrfProtectionSetting)
}

// Main query logic to find CSRF vulnerabilities in production environments
// Ensures consistent vulnerability detection across all production configurations
from Http::Server::CsrfProtectionSetting csrfProtectionSetting
where
  hasInsufficientCsrfProtection(csrfProtectionSetting) and
  // Verify that all production CSRF settings share the same vulnerable state
  forall(Http::Server::CsrfProtectionSetting alternativeCsrfSetting | 
         isProductionCsrfConfig(alternativeCsrfSetting) | 
         hasInsufficientCsrfProtection(alternativeCsrfSetting))
select csrfProtectionSetting, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."