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

// 从Cryptography::PublicKey::KeyGeneration类中导入keyGen，int类型的keySize和DataFlow::Node类型的origin
from Cryptography::PublicKey::KeyGeneration keyGen, int keySize, DataFlow::Node origin
where
  // 获取keyGen的密钥大小并检查其是否小于最小安全密钥大小
  keySize = keyGen.getKeySizeWithOrigin(origin) and
  keySize < keyGen.minimumSecureKeySize() and
  // 确保origin的作用域不是测试作用域
  not origin.getScope().getScope*() instanceof TestScope
select keyGen,
  // 选择生成的密钥信息，包括类型、大小以及警告信息
  "Creation of an " + keyGen.getName() + " key uses $@ bits, which is below " +
    keyGen.minimumSecureKeySize() + " and considered breakable.", origin, keySize.toString()
