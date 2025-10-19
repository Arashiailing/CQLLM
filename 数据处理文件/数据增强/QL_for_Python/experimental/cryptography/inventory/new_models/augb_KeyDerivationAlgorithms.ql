/**
 * @name Key Derivation Algorithms
 * @description Identifies all instances where key derivation functions are utilized
 *              through supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-derivation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 查询所有密钥派生操作实例
from KeyDerivationOperation kdfOperation
// 提取密钥派生算法的名称信息
where exists(kdfOperation.getAlgorithm().(KeyDerivationAlgorithm))
// 构建描述性消息，包含算法名称
select kdfOperation,
  "Key derivation function detected: " + 
  kdfOperation.getAlgorithm().(KeyDerivationAlgorithm).getKDFName() + 
  " - This cryptographic operation may have quantum vulnerabilities"