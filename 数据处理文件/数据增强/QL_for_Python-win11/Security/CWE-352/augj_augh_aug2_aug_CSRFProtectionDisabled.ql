/**
 * @name CSRF protection weakened or disabled
 * @description Identifies applications where CSRF protection mechanisms have been
 *              disabled or weakened, making them vulnerable to Cross-Site Request
 *              Forgery attacks that could allow unauthorized actions.
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

// Helper predicate to identify CSRF configurations in production code
// This predicate excludes test configurations that may intentionally disable CSRF
predicate isProductionConfiguration(Http::Server::CsrfProtectionSetting csrfConfig) {
  // Exclude configurations in test files by checking file path patterns
  // This approach catches test configurations that might not be flagged by TestScope
  not csrfConfig.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate to identify CSRF configurations with insufficient protection
// This detects security risks created by disabled or weakened CSRF mechanisms
predicate hasInsufficientProtection(Http::Server::CsrfProtectionSetting csrfConfig) {
  // A configuration is vulnerable when all conditions are met:
  // 1. CSRF verification is explicitly disabled
  // 2. No local CSRF protection alternative is enabled
  // 3. The configuration is in production code (not test environments)
  csrfConfig.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localProtection | localProtection.csrfEnabled()) and
  isProductionConfiguration(csrfConfig)
}

// Main query to identify all CSRF protection vulnerabilities
// This locates configurations that are both vulnerable and representative of
// the application's actual security posture (excluding test configurations)
from Http::Server::CsrfProtectionSetting csrfConfig
where
  // The configuration must meet our vulnerability criteria
  hasInsufficientProtection(csrfConfig) and
  // Verify this is a genuine security issue by ensuring no secure
  // CSRF configurations exist in the same production codebase
  not exists(Http::Server::CsrfProtectionSetting secureConfig |
    isProductionConfiguration(secureConfig) and
    not hasInsufficientProtection(secureConfig)
  )
select csrfConfig, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."