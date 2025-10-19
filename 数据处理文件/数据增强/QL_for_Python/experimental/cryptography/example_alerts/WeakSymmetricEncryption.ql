/**
 * @name Weak symmetric encryption algorithm
 * @description Finds uses of symmetric cryptography algorithms that are weak, obsolete, or otherwise unaccepted.
 *
 *              The key lengths allowed are 128, 192, and 256 bits. These are all the key lengths supported by AES, so any
 *              application of AES is considered acceptable.
 * @id py/weak-symmetric-encryption
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python // 导入python库，用于分析Python代码
import experimental.cryptography.Concepts // 导入实验性加密概念库，用于处理加密相关的概念

// 从SymmetricEncryptionAlgorithm操作符中选择op、name和msg字段
from SymmetricEncryptionAlgorithm op, string name, string msg
where
  // 获取加密算法的名称并赋值给变量name
  name = op.getEncryptionName() and
  // 过滤掉AES及其变种（AES128, AES192, AES256）的加密算法
  not name = ["AES", "AES128", "AES192", "AES256"] and
  // 如果算法名称未知，则设置消息为“使用未识别的对称加密算法”
  if name = unknownAlgorithm()
  then msg = "Use of unrecognized symmetric encryption algorithm."
  // 否则，设置消息为“使用未经批准的对称加密算法或API”并附加算法名称
  else msg = "Use of unapproved symmetric encryption algorithm or API " + name + "."
// 选择操作符op和消息msg作为查询结果
select op, msg
