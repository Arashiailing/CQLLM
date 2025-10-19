/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * This rule identifies the use of asymmetric padding algorithms that are either weak, unapproved, or have unknown security properties.
 * Secure asymmetric padding schemes include OAEP, KEM, and PSS; other schemes may introduce security risks.
 * By detecting these insecure padding schemes, we can help prevent potential cryptographic vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// 定义已知的强填充方案列表
string securePaddingMethods() { result = ["OAEP", "KEM", "PSS"] }

// 查找所有非安全的非对称填充算法实例
from AsymmetricPadding paddingMethod, string methodName
where 
  // 获取当前填充方法的名称
  methodName = paddingMethod.getPaddingName()
  // 确保该填充方法不在安全填充方案列表中
  and methodName != securePaddingMethods()
select paddingMethod, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + methodName