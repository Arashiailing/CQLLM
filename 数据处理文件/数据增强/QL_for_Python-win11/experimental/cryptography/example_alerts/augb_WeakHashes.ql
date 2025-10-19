/**
 * @name Weak hashes
 * @description Finds uses of cryptography algorithms that are unapproved or otherwise weak.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// 引入Python语言支持及密码学相关概念库
import python
import experimental.cryptography.Concepts

// 识别哈希算法操作、算法名称及相应警告消息
from HashAlgorithm hashOperation, string hashName, string warningMessage
where
  // 步骤1：提取哈希算法名称
  hashName = hashOperation.getHashName() and
  // 步骤2：排除已批准的强哈希算法
  not hashName = ["SHA256", "SHA384", "SHA512"] and
  // 步骤3：根据算法是否可识别生成相应的警告消息
  if hashName = unknownAlgorithm()
  then warningMessage = "Use of unrecognized hash algorithm."
  else warningMessage = "Use of unapproved hash algorithm or API " + hashName + "."
select hashOperation, warningMessage