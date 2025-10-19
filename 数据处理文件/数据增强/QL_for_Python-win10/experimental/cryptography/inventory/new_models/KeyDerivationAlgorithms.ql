/**
 * @name Key Derivation Algorithms
 * @description Finds all potential usage of key derivation using the supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-derivation
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 从KeyDerivationOperation类中选择操作对象op
from KeyDerivationOperation op
// TODO: 从操作对象中提取所有配置？
select op,
  // 使用密钥派生算法的详细信息，包括算法名称
  "Use of key derivation algorithm " + op.getAlgorithm().(KeyDerivationAlgorithm).getKDFName()
