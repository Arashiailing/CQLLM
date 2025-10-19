/**
 * @name Hash Algorithms
 * @description Finds all potential usage of cryptographic hash algorithms using the supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入Python库和Semmle Python概念库
import python
import semmle.python.Concepts

// 从Cryptography::CryptographicOperation类中选择操作和算法
from Cryptography::CryptographicOperation operation, Cryptography::CryptographicAlgorithm algorithm
where
  // 条件：算法是操作的算法，并且算法是哈希算法或密码哈希算法的实例
  algorithm = operation.getAlgorithm() and
  (
    algorithm instanceof Cryptography::HashingAlgorithm or
    algorithm instanceof Cryptography::PasswordHashingAlgorithm
  )
// 选择操作并返回使用算法的名称
select operation, "Use of algorithm " + operation.getAlgorithm().getName()
