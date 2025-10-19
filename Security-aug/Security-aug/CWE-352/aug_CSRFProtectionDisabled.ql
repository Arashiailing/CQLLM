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

// Predicate to identify non-test CSRF protection configurations
predicate isRelevantConfiguration(Http::Server::CsrfProtectionSetting config) {
  // Exclude test configurations where CSRF is commonly disabled
  // Uses path-based exclusion instead of TestScope to catch integration test settings
  not config.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate to detect vulnerable CSRF configurations
predicate isVulnerableConfiguration(Http::Server::CsrfProtectionSetting config) {
  // Conditions for vulnerability:
  // 1. CSRF verification is disabled
  // 2. No local CSRF protection is enabled
  // 3. Configuration is in non-test code
  config.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localProt | localProt.csrfEnabled()) and
  isRelevantConfiguration(config)
}

// Query to identify all vulnerable CSRF configurations
from Http::Server::CsrfProtectionSetting config
where
  // Current configuration must be vulnerable
  isVulnerableConfiguration(config) and
  // Ensure all non-test configurations are vulnerable (eliminate false positives from dummy projects)
  not exists(Http::Server::CsrfProtectionSetting otherConfig |
    isRelevantConfiguration(otherConfig) and
    not isVulnerableConfiguration(otherConfig)
  )
select config, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."