/**
 * @name CSRF protection weakened or disabled
 * @description Disabling or weakening CSRF protection may make the application
 *              vulnerable to a Cross-Site Request Forgery (CSRF) attack.
 * @id py/networkmanager
 */
import python
import semmle.python.Concepts

// Define a predicate function to check if the given CSRF protection setting is relevant (i.e., not test code)
predicate relevantSetting(Http::Server::CsrfProtectionSetting s) {
  // Exclude test code, because this is a common place where CSRF protection is disabled.
  // We don't use the normal `TestScope` to find test files, because we also want to match files like `.../integration-tests/settings.py`.
  not s.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Define a predicate function to check if the given CSRF protection setting is vulnerable (i.e., CSRF protection is disabled or weakened)
predicate vulnerableSetting(Http::Server::CsrfProtectionSetting s) {
  // Check if the CSRF verification setting is false, and there does not exist any enabled CSRF local protection setting, while the setting is relevant (non-test code)
  s.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting p | p.csrfEnabled()) and
  relevantSetting(s)
}

// From all HTTP server's CSRF protection settings, select those that are vulnerable and generate corresponding warning information
from Http::Server::CsrfProtectionSetting setting
where
  // The current setting is vulnerable
  vulnerableSetting(setting) and
  // We already see some virtual projects next to main projects with vulnerable setting files. We need to exclude such cases, so require all non-test settings to be vulnerable.
  forall(Http::Server::CsrfProtectionSetting s | relevantSetting(s) | vulnerableSetting(s))
select setting, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."