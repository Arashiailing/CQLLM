/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * This rule identifies instances where asymmetric padding algorithms that are weak, unapproved, or of unknown security are utilized.
 * Secure asymmetric padding schemes include OAEP, KEM, and PSS; other schemes might be insecure.
 * By flagging these insecure padding schemes, we can help prevent potential security vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// 从 AsymmetricPadding 类中获取填充方案实例及其名称
from AsymmetricPadding paddingScheme, string paddingName
where 
  // 提取当前填充方案的名称
  paddingName = paddingScheme.getPaddingName()
  // 排除已知的强填充方案
  and not paddingName = ["OAEP", "KEM", "PSS"]
select paddingScheme, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingName