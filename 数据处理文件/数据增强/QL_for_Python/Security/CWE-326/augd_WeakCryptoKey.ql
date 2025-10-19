/**
 * @name 使用弱加密密钥
 * @description 检测使用长度不足的加密密钥，这些密钥可能被破解。
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

// 从加密密钥生成器类中获取相关参数
from Cryptography::PublicKey::KeyGeneration cryptoKeyGenerator, int securityKeySize, DataFlow::Node sourceNode
where
  // 获取密钥大小并验证其安全性
  securityKeySize = cryptoKeyGenerator.getKeySizeWithOrigin(sourceNode) and
  // 检查密钥大小是否低于最小安全标准
  securityKeySize < cryptoKeyGenerator.minimumSecureKeySize() and
  // 确保密钥生成不在测试代码中
  not sourceNode.getScope().getScope*() instanceof TestScope
select cryptoKeyGenerator,
  // 生成警告信息，包含密钥类型、大小和安全建议
  "Creation of an " + cryptoKeyGenerator.getName() + " key uses $@ bits, which is below " +
    cryptoKeyGenerator.minimumSecureKeySize() + " and considered breakable.", sourceNode, securityKeySize.toString()