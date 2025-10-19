/**
 * @name All Cryptographic Algorithms
 * @description Finds all potential usage of cryptographic algorithms usage using the supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入Python库和Semmle Python概念库
import python
import semmle.python.Concepts

// 从Cryptography类中选择加密操作和算法名称
from Cryptography::CryptographicOperation operation, string algName
where
  // 获取加密操作的算法名称
  algName = operation.getAlgorithm().getName()
  or
  // 获取加密操作的块模式
  algName = operation.getBlockMode()
select operation, "Use of algorithm " + algName
