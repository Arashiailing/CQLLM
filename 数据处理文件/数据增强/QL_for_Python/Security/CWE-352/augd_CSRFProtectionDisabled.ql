/**
 * @name CSRF protection weakened or disabled
 * @description When CSRF protection is disabled or weakened, the application
 *              becomes susceptible to Cross-Site Request Forgery (CSRF) attacks.
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

// Predicate to determine if a CSRF protection setting is relevant (i.e., not in test code)
predicate isRelevantCsrfConfig(Http::Server::CsrfProtectionSetting csrfConfig) {
  // Exclude test code, as this is a common place where CSRF protection is disabled.
  // We don't use the normal `TestScope` to find test files because we also want to match
  // setting files such as `.../integration-tests/settings.py`.
  not csrfConfig.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate to determine if a CSRF protection setting is vulnerable (i.e., CSRF protection is disabled or weakened)
predicate isVulnerableCsrfConfig(Http::Server::CsrfProtectionSetting csrfConfig) {
  // Check if the setting is relevant (not in test code)
  isRelevantCsrfConfig(csrfConfig) and
  // Check if CSRF verification is disabled
  csrfConfig.getVerificationSetting() = false and
  // Check if there's no local CSRF protection enabled
  not exists(Http::Server::CsrfLocalProtectionSetting localProtection | localProtection.csrfEnabled())
}

// Select all vulnerable CSRF protection settings from HTTP servers and generate corresponding warning messages
from Http::Server::CsrfProtectionSetting csrfSetting
where
  // The current setting is vulnerable
  isVulnerableCsrfConfig(csrfSetting) and
  // We've observed some dummy projects with vulnerable setting files alongside the main project.
  // To exclude this case, we require that all non-test settings must be vulnerable.
  forall(Http::Server::CsrfProtectionSetting s | isRelevantCsrfConfig(s) | isVulnerableCsrfConfig(s))
select csrfSetting, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."