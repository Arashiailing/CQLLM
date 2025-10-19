/**
 * @name Weak or unknown asymmetric padding
 * @description
 * This query detects the use of weak, unapproved, or unknown asymmetric padding schemes.
 * Asymmetric padding schemes like OAEP, KEM, and PSS are considered secure, while others may not be.
 * Identifying these weak padding schemes helps in mitigating potential security risks.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// 从 AsymmetricPadding 类中获取 pad 和 name 变量
from AsymmetricPadding pad, string name
where
  // 获取填充方案的名称，并检查其是否为已知的安全填充方案
  name = pad.getPaddingName() and
  not name = ["OAEP", "KEM", "PSS"]
select pad, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + name
