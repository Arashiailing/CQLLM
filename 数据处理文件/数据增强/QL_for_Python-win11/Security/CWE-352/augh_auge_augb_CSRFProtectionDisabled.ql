/**
 * @name CSRF protection weakened or disabled
 * @description This query detects configurations where Cross-Site Request Forgery (CSRF) 
 *              protection is either disabled or weakened, making the application
 *              vulnerable to CSRF attacks.
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

// Predicate to identify CSRF configurations from production environments (excluding test files)
predicate isProductionConfig(Http::Server::CsrfProtectionSetting csrfSetting) {
  // Exclude test files (files containing "test" in their path)
  not csrfSetting.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate to identify CSRF configurations with security vulnerabilities
predicate isVulnerableToCsrf(Http::Server::CsrfProtectionSetting csrfSetting) {
  // Check if CSRF verification is disabled and no local CSRF protection is enabled
  csrfSetting.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localCsrfDefense | 
             localCsrfDefense.csrfEnabled()) and
  isProductionConfig(csrfSetting)
}

// Main query to find vulnerable CSRF configurations while ensuring consistent analysis
// This approach minimizes false positives by requiring all production configs to be vulnerable
from Http::Server::CsrfProtectionSetting vulnerableCsrfSetting
where
  // Ensure all production configurations are vulnerable to exclude false positives from virtual projects
  forall(Http::Server::CsrfProtectionSetting prodCsrfSetting | 
         isProductionConfig(prodCsrfSetting) | 
         isVulnerableToCsrf(prodCsrfSetting)) and
  // Current configuration is vulnerable
  isVulnerableToCsrf(vulnerableCsrfSetting)
select vulnerableCsrfSetting, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."