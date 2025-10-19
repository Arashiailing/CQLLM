/**
 * @name CSRF protection weakened or disabled
 * @description Disabling or weakening CSRF protection may make the application
 * vulnerable to a Cross-Site Request Forgery (CSRF) attack.
 * @id py/qutescheme
 */
import python
import semmle.python.Concepts

predicate relevantSetting(Http::Server::CsrfProtectionSetting s) {
  not s.getLocation().getFile().getAbsolutePath().matches("%test%")
}

predicate vulnerableSetting(Http::Server::CsrfProtectionSetting s) {
  s.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting p | p.csrfEnabled()) and
  relevantSetting(s)
}

from Http::Server::CsrfProtectionSetting setting
where vulnerableSetting(setting)
forall(Http::Server::CsrfProtectionSetting s | relevantSetting(s) | vulnerableSetting(s))
select setting, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."