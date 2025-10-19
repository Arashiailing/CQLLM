/**
 * @name Detection of weak or unidentified asymmetric padding
 * @description
 * This query identifies cryptographic implementations that utilize asymmetric padding schemes
 * which are either weak, not approved, or unrecognized. Secure padding schemes such as OAEP,
 * KEM, and PSS are considered safe, whereas other schemes may introduce vulnerabilities.
 * Detection of these insecure padding practices is crucial for maintaining cryptographic security.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// 查询所有非安全的非对称填充方案
from AsymmetricPadding asymmetricPadding, string paddingName
where
  // 获取当前填充方案的名称
  paddingName = asymmetricPadding.getPaddingName() and
  // 检查该填充方案是否不在已知的安全填充方案列表中
  not paddingName in ["OAEP", "KEM", "PSS"]
select asymmetricPadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingName