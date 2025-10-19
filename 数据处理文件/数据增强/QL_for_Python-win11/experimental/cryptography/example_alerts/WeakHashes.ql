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

// 从HashAlgorithm操作符、字符串名称和消息中选择数据
from HashAlgorithm op, string name, string msg
where
  // 获取哈希算法的名称并赋值给变量name
  name = op.getHashName() and
  // 过滤掉SHA256, SHA384, SHA512这些被认可的强哈希算法
  not name = ["SHA256", "SHA384", "SHA512"] and
  // 如果哈希算法名称未知，则设置消息为“使用未识别的哈希算法”
  if name = unknownAlgorithm()
  then msg = "Use of unrecognized hash algorithm."
  // 否则，设置消息为“使用未经批准的哈希算法或API”并附加算法名称
  else msg = "Use of unapproved hash algorithm or API " + name + "."
select op, msg
