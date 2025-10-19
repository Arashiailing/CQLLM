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

// Predicate to identify CSRF configurations from production environments (excluding test files)
predicate isNonTestConfiguration(Http::Server::CsrfProtectionSetting csrfConfig) {
  // Exclude test files (files containing "test" in their path)
  not csrfConfig.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate to identify CSRF configurations with security vulnerabilities
predicate hasSecurityRisk(Http::Server::CsrfProtectionSetting csrfConfig) {
  // Check if CSRF verification is disabled and no local CSRF protection is enabled
  csrfConfig.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localCsrfProtection | 
             localCsrfProtection.csrfEnabled()) and
  isNonTestConfiguration(csrfConfig)
}

// Main query to find vulnerable CSRF configurations while ensuring consistent analysis
// This approach minimizes false positives by requiring all production configs to be vulnerable
from Http::Server::CsrfProtectionSetting vulnerableCsrfConfig
where
  // Current configuration is vulnerable
  hasSecurityRisk(vulnerableCsrfConfig) and
  // Ensure all production configurations are vulnerable to exclude false positives from virtual projects
  forall(Http::Server::CsrfProtectionSetting nonTestCsrfConfig | 
         isNonTestConfiguration(nonTestCsrfConfig) | 
         hasSecurityRisk(nonTestCsrfConfig))
select vulnerableCsrfConfig, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."