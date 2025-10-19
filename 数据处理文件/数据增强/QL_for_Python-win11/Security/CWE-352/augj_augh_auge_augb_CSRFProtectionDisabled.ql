/**
 * @name CSRF protection weakened or disabled
 * @description Identifies application configurations where Cross-Site Request Forgery (CSRF) 
 *              safeguards are either deactivated or compromised, potentially exposing
 *              the system to CSRF-based attacks.
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

// Filter to identify CSRF configurations from production environments (excluding test files)
predicate isProductionEnvironmentConfig(Http::Server::CsrfProtectionSetting csrfConfig) {
  // Exclude test files (files containing "test" in their path)
  not csrfConfig.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Filter to identify CSRF configurations with security vulnerabilities
predicate hasCsrfVulnerability(Http::Server::CsrfProtectionSetting csrfConfig) {
  // Verify if CSRF verification is disabled and no local CSRF protection is active
  csrfConfig.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localCsrfProtection | 
             localCsrfProtection.csrfEnabled()) and
  isProductionEnvironmentConfig(csrfConfig)
}

// Main query to detect vulnerable CSRF configurations while maintaining analysis consistency
// This method reduces false positives by ensuring all production configs are vulnerable
from Http::Server::CsrfProtectionSetting vulnerableCsrfConfig
where
  // Validate that all production configurations are vulnerable to eliminate false positives from virtual projects
  forall(Http::Server::CsrfProtectionSetting productionCsrfConfig | 
         isProductionEnvironmentConfig(productionCsrfConfig) | 
         hasCsrfVulnerability(productionCsrfConfig)) and
  // The current configuration is vulnerable
  hasCsrfVulnerability(vulnerableCsrfConfig)
select vulnerableCsrfConfig, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."