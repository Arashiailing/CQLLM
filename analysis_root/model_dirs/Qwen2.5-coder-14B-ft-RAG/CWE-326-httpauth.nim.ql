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
// 检查条件：
// 1. keyGen是私钥生成器，且其最小密钥长度小于1024位
// 2. 原始参数具有合理的默认值
where
  keyGen.isPrivateKeyGenerator() and
  keySize = keyGen.minimumKeyLength() and
  keySize < 1024 and
  origin = keyGen.getKeySizeOrigin()
// 选择结果：
// 1. 原始参数的位置
// 2. 关键生成器实例
// 3. 密钥尺寸
// 4. 描述消息，包括关键生成器类型、尺寸和原始位置
select origin.getLocation(), keyGen,
  "Creation of private key where minimum key length is $@ bits from $@", keySize, origin.toString()