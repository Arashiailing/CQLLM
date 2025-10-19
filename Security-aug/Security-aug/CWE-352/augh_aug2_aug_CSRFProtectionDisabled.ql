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

// Helper predicate to determine if a CSRF configuration is in production code
// This excludes test configurations that might have intentionally disabled CSRF
predicate isInProductionCode(Http::Server::CsrfProtectionSetting csrfSetting) {
  // Filter out configurations located in test files using path pattern matching
  // This complements TestScope by catching test configurations not otherwise flagged
  not csrfSetting.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate to detect CSRF configurations that are vulnerable to attacks
// This identifies settings that create a security risk by disabling protection
predicate hasInsufficientCsrfProtection(Http::Server::CsrfProtectionSetting csrfSetting) {
  // A configuration is considered vulnerable when:
  // 1. CSRF verification is explicitly turned off
  // 2. No alternative local CSRF protection is in place
  // 3. The configuration affects production code (not test environments)
  csrfSetting.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localCsrfProtection | localCsrfProtection.csrfEnabled()) and
  isInProductionCode(csrfSetting)
}

// Main query that identifies all CSRF protection vulnerabilities
// This finds configurations that are both vulnerable and representative of
// the application's actual security posture (excluding test/dummy configurations)
from Http::Server::CsrfProtectionSetting csrfSetting
where
  // The configuration must satisfy our vulnerability criteria
  hasInsufficientCsrfProtection(csrfSetting) and
  // Ensure this is a genuine security issue by verifying there are no
  // secure CSRF configurations in the same production codebase
  not exists(Http::Server::CsrfProtectionSetting alternativeCsrfSetting |
    isInProductionCode(alternativeCsrfSetting) and
    not hasInsufficientCsrfProtection(alternativeCsrfSetting)
  )
select csrfSetting, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."