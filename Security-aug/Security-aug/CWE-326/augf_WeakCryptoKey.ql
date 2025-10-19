/**
 * @name Use of weak cryptographic key
 * @description Detects cryptographic keys with insufficient length that could be compromised.
 *              Keys below the minimum secure size are vulnerable to brute force attacks.
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

// 检索所有加密密钥生成器实例及其相关参数
from Cryptography::PublicKey::KeyGeneration cryptoKeyGenerator, int cryptoKeyLength, DataFlow::Node keySizeSource
where
  // 获取密钥生成器创建的密钥长度及其来源节点
  cryptoKeyLength = cryptoKeyGenerator.getKeySizeWithOrigin(keySizeSource) and
  // 验证密钥长度是否低于安全阈值
  cryptoKeyLength < cryptoKeyGenerator.minimumSecureKeySize() and
  // 排除测试代码中的密钥生成，以减少误报
  not keySizeSource.getScope().getScope*() instanceof TestScope
select cryptoKeyGenerator,
  // 生成警告消息，指出弱密钥的使用
  "Creation of an " + cryptoKeyGenerator.getName() + " key uses $@ bits, which is below " +
    cryptoKeyGenerator.minimumSecureKeySize() + " and considered breakable.", keySizeSource, cryptoKeyLength.toString()