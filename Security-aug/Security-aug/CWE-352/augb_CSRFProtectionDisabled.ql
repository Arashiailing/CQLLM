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

// 判断CSRF配置是否来自非测试环境（排除测试文件中的配置）
predicate isNonTestConfiguration(Http::Server::CsrfProtectionSetting config) {
  // 排除测试文件（路径包含"test"的文件），因为测试环境常禁用CSRF保护
  not config.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// 判断CSRF配置是否存在安全风险（保护被禁用或弱化）
predicate hasSecurityRisk(Http::Server::CsrfProtectionSetting config) {
  // 检查CSRF验证是否被禁用，且没有启用本地CSRF保护，同时配置来自非测试环境
  config.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localProtection | 
             localProtection.csrfEnabled()) and
  isNonTestConfiguration(config)
}

// 查找存在安全风险的CSRF配置，并确保所有非测试配置都存在风险（排除虚拟项目干扰）
from Http::Server::CsrfProtectionSetting vulnerableConfig
where
  // 当前配置存在安全风险
  hasSecurityRisk(vulnerableConfig) and
  // 排除虚拟项目干扰：要求所有非测试配置都必须存在安全风险
  forall(Http::Server::CsrfProtectionSetting nonTestConfig | 
         isNonTestConfiguration(nonTestConfig) | 
         hasSecurityRisk(nonTestConfig))
select vulnerableConfig, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."