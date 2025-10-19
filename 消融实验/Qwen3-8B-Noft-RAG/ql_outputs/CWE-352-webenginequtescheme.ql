/**
 * @name CSRF protection weakened or disabled
 * @id py/webenginequtescheme
 */
import python
import semmle.python.Concepts

// 定义相关设置谓词（排除测试代码）
predicate relevantSetting(Http::Server::CsrfProtectionSetting s) {
  not s.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// 定义易受攻击的设置谓词（CSRF保护被禁用或弱化）
predicate vulnerableSetting(Http::Server::CsrfProtectionSetting s) {
  s.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting p | p.csrfEnabled()) and
  relevantSetting(s)
}

// 选择所有易受攻击的CSRF设置并生成警告
from Http::Server::CsrfProtectionSetting setting
where vulnerableSetting(setting) and
  forall(Http::Server::CsrfProtectionSetting s | relevantSetting(s) | vulnerableSetting(s))
select setting, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."