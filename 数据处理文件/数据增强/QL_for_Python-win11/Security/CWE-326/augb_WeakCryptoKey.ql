/**
 * @name Use of weak cryptographic key
 * @description Use of a cryptographic key that is too small may allow the encryption to be broken.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/weak-crypto-key
 * @tags security
 *       external/cwe/cwe-326
 */

import python
import semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow
import semmle.python.filters.Tests

// 查询目标：识别使用不安全密钥长度的加密密钥生成操作
from Cryptography::PublicKey::KeyGeneration keyCreation, int weakKeySize, DataFlow::Node sourceNode
where
  // 获取密钥生成操作中的密钥大小及其来源节点
  weakKeySize = keyCreation.getKeySizeWithOrigin(sourceNode) and
  // 验证密钥大小是否低于安全阈值
  weakKeySize < keyCreation.minimumSecureKeySize() and
  // 确保密钥生成不在测试代码范围内
  not sourceNode.getScope().getScope*() instanceof TestScope
select keyCreation,
  "Creation of an " + keyCreation.getName() + " key uses $@ bits, which is below " +
    keyCreation.minimumSecureKeySize() + " and considered breakable.", sourceNode, weakKeySize.toString()