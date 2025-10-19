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

// Helper predicate to exclude test-related CSRF configurations
// This predicate ensures analysis focuses on production code where security matters
predicate isProductionCsrfConfig(Http::Server::CsrfProtectionSetting csrfSetting) {
  // Filter out test files using path pattern matching
  // This method helps identify test configurations that might bypass TestScope detection
  not csrfSetting.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate to detect CSRF configurations with inadequate protection
// This predicate identifies specific conditions that constitute a security vulnerability
predicate hasInsufficientCsrfProtection(Http::Server::CsrfProtectionSetting csrfSetting) {
  // A configuration is considered vulnerable when:
  // 1. CSRF verification is explicitly turned off
  // 2. No alternative local CSRF protection mechanism is in place
  // 3. The configuration applies to production code (excludes test environments)
  csrfSetting.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localProtection | localProtection.csrfEnabled()) and
  isProductionCsrfConfig(csrfSetting)
}

// Core query logic to identify all CSRF protection vulnerabilities
// This query finds configurations that are both vulnerable and representative
// of the application's actual security posture (excluding test/dummy configurations)
from Http::Server::CsrfProtectionSetting csrfSetting
where
  // The configuration must satisfy our vulnerability criteria
  hasInsufficientCsrfProtection(csrfSetting) and
  // Ensure this is a genuine security issue by verifying
  // that no secure CSRF configurations exist in production code
  not exists(Http::Server::CsrfProtectionSetting secureConfig |
    isProductionCsrfConfig(secureConfig) and
    not hasInsufficientCsrfProtection(secureConfig)
  )
select csrfSetting, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."