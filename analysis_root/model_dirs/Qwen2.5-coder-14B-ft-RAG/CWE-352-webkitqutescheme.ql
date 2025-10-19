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

// 定义一个谓词函数，用于判断给定的CSRF保护设置是否相关（即不是测试代码中的设置）
predicate relevantSetting(Http::Server::CsrfProtectionSetting s) {
  // 排除测试代码，因为这是禁用CSRF保护的常见地方。
  // 我们不使用正常的`TestScope`来查找测试文件，因为我们还想匹配诸如`.../integration-tests/settings.py`这样的设置文件。
  not s.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// 定义一个谓词函数，用于判断给定的CSRF保护设置是否易受攻击（即CSRF保护被禁用或弱化）
predicate vulnerableSetting(Http::Server::CsrfProtectionSetting s) {
  // 检查CSRF验证设置是否为false，并且不存在任何启用了CSRF本地保护的设置，同时该设置是相关的（非测试代码）
  s.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting p | p.csrfEnabled()) and
  relevantSetting(s)
}

// 从所有HTTP服务器的CSRF保护设置中选择那些易受攻击的设置，并生成相应的警告信息
from Http::Server::CsrfProtectionSetting setting
where
  // 当前设置是易受攻击的
  vulnerableSetting(setting) and
  // 我们已看到一些虚拟项目在主项目旁边有易受攻击的设置文件。我们需要排除这种情况，因此要求所有非测试设置都必须是易受攻击的。
  forall(Http::Server::CsrfProtectionSetting s | relevantSetting(s) | vulnerableSetting(s))
select setting, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."