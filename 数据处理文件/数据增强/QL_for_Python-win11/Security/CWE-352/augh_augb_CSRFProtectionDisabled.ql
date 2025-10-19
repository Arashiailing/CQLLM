/**
 * @name CSRF protection weakened or disabled
 * @description This query identifies instances where CSRF protection mechanisms
 *              are either disabled or weakened, potentially exposing the application
 *              to Cross-Site Request Forgery attacks.
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

// 判断CSRF配置是否来自生产环境（排除测试文件中的配置）
predicate isProductionCsrfSetting(Http::Server::CsrfProtectionSetting csrfSetting) {
  // 排除测试文件（路径包含"test"的文件），因为测试环境常禁用CSRF保护
  not csrfSetting.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// 判断CSRF配置是否存在安全风险（保护被禁用或弱化）
predicate hasCsrfSecurityRisk(Http::Server::CsrfProtectionSetting csrfSetting) {
  // 检查CSRF验证是否被禁用，且没有启用本地CSRF保护，同时配置来自生产环境
  csrfSetting.getVerificationSetting() = false and
  not exists(Http::Server::CsrfLocalProtectionSetting localProtection | 
             localProtection.csrfEnabled()) and
  isProductionCsrfSetting(csrfSetting)
}

// 查找存在安全风险的CSRF配置，并确保所有生产环境配置都存在风险（排除虚拟项目干扰）
from Http::Server::CsrfProtectionSetting atRiskCsrfConfig
where
  // 当前配置存在安全风险
  hasCsrfSecurityRisk(atRiskCsrfConfig) and
  // 排除虚拟项目干扰：要求所有生产环境配置都必须存在安全风险
  forall(Http::Server::CsrfProtectionSetting productionCsrfConfig | 
         isProductionCsrfSetting(productionCsrfConfig) | 
         hasCsrfSecurityRisk(productionCsrfConfig))
select atRiskCsrfConfig, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."