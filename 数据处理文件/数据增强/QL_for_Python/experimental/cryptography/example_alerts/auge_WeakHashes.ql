/**
 * @name Weak hashes
 * @description Finds uses of cryptography algorithms that are unapproved or otherwise weak.
 * @id py/weak-hashes
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

// 导入Python库和实验性加密概念库
import python
import experimental.cryptography.Concepts

// 从哈希操作中提取数据
from HashAlgorithm hashOperation, string algorithmName, string warningMessage
where
  // 获取哈希算法名称
  algorithmName = hashOperation.getHashName() and
  // 排除批准使用的强哈希算法
  not algorithmName = ["SHA256", "SHA384", "SHA512"] and
  // 根据算法识别状态生成相应警告消息
  if algorithmName = unknownAlgorithm()
  then warningMessage = "Use of unrecognized hash algorithm."
  else warningMessage = "Use of unapproved hash algorithm or API " + algorithmName + "."
select hashOperation, warningMessage