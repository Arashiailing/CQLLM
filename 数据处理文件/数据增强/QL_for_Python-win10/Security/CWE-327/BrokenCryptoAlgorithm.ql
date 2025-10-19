/**
 * @name Use of a broken or weak cryptographic algorithm
 * @description Using broken or weak cryptographic algorithms can compromise security.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @id py/weak-cryptographic-algorithm
 * @tags security
 *       external/cwe/cwe-327
 */

import python
import semmle.python.Concepts

// 从Cryptography模块中导入CryptographicOperation类和字符串msgPrefix
from Cryptography::CryptographicOperation operation, string msgPrefix
where
  // 如果存在一个加密算法，并且该算法是弱的，则设置消息前缀为"使用了一个弱的加密算法"
  exists(Cryptography::EncryptionAlgorithm algorithm | algorithm = operation.getAlgorithm() |
    algorithm.isWeak() and
    msgPrefix = "The cryptographic algorithm " + algorithm.getName()
  )
  // 或者如果操作的块模式是弱的，则设置消息前缀为"使用了一个弱的块模式"
  or
  operation.getBlockMode().isWeak() and msgPrefix = "The block mode " + operation.getBlockMode()
select operation, "$@ is broken or weak, and should not be used.", operation.getInitialization(),
  msgPrefix
