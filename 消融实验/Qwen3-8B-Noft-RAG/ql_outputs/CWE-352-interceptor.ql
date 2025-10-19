import python
import semmle.python.Concepts

/** @name CSRF protection weakened or disabled */
from Http::Server::CsrfProtectionSetting setting
where
  setting.getVerificationSetting() = false
  and not exists(Http::Server::CsrfLocalProtectionSetting p | p.csrfEnabled())
  and not setting.getLocation().getFile().getAbsolutePath().matches("%test%")
  and forall(Http::Server::CsrfProtectionSetting s | not s.getLocation().getFile().getAbsolutePath().matches("%test%") | vulnerableSetting(s))
select setting, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."