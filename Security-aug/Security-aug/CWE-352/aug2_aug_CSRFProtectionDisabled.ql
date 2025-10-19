/**
 * @name CSRF protection weakened or disabled
 * @description Applications with disabled or weakened CSRF protection are susceptible
 *              to Cross-Site Request Forgery (CSRF) attacks, allowing malicious actors
 *              to perform unauthorized actions on behalf of authenticated users.
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

// Predicate to filter out test-related CSRF configurations
// This ensures we only analyze production code where CSRF protection matters
predicate isRelevantConfiguration(Http::Server::CsrfProtectionSetting csrfConfig) {
  // Exclude test files based on path pattern matching
  // This approach catches test configurations that might not be flagged by TestScope
  not csrfConfig.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate to identify configurations with insufficient CSRF protection
// This checks for the specific conditions that create a vulnerability
predicate isVulnerableConfiguration(Http::Server::CsrfProtectionSetting csrfConfig) {
  // A configuration is vulnerable when:
  // 1. CSRF verification is explicitly disabled
  // 2. No alternative local CSRF protection mechanism is active
  // 3. The configuration is in production code (not tests)
  csrfConfig.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localProtection | localProtection.csrfEnabled()) and
  isRelevantConfiguration(csrfConfig)
}

// Main query to detect all CSRF protection vulnerabilities
// This identifies configurations that are both vulnerable and representative
// of the application's security posture (not just dummy/test configurations)
from Http::Server::CsrfProtectionSetting csrfConfig
where
  // The current configuration must meet our vulnerability criteria
  isVulnerableConfiguration(csrfConfig) and
  // Validate that this represents a true security issue by ensuring
  // there are no secure CSRF configurations in non-test code
  not exists(Http::Server::CsrfProtectionSetting alternativeConfig |
    isRelevantConfiguration(alternativeConfig) and
    not isVulnerableConfiguration(alternativeConfig)
  )
select csrfConfig, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."