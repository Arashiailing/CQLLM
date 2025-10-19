/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies usage of asymmetric encryption padding schemes that are either weak,
 * not approved, or unknown. Secure padding schemes include OAEP, KEM, and PSS.
 * Detection of such insecure padding helps prevent potential cryptographic vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// 查找所有非对称填充方案实例
from AsymmetricPadding asymmetricPadding, string schemeName
where
  // 获取当前填充方案的名称
  schemeName = asymmetricPadding.getPaddingName() and
  // 检查该方案是否不在安全填充方案列表中
  not schemeName = ["OAEP", "KEM", "PSS"]
select asymmetricPadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + schemeName