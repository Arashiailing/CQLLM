/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * Identifies usage of asymmetric padding algorithms that are considered weak, 
 * unapproved, or have unknown security properties. Approved secure asymmetric 
 * padding schemes include OAEP, KEM, and PSS. All other padding schemes may 
 * introduce security vulnerabilities and should be avoided.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// 查找所有非安全的不对称填充算法实例
from AsymmetricPadding asymmetricPadding, string paddingAlgorithmName
where 
  // 获取当前填充算法的名称
  paddingAlgorithmName = asymmetricPadding.getPaddingName()
  // 确保填充算法不在已批准的安全填充方案列表中
  and paddingAlgorithmName != "OAEP"
  and paddingAlgorithmName != "KEM"
  and paddingAlgorithmName != "PSS"
select asymmetricPadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingAlgorithmName