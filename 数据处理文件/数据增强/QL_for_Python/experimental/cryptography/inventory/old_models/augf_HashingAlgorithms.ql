/**
 * @name Hash Algorithms
 * @description 检测所有使用支持的加密库中加密哈希算法的潜在用法。
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入必要的Python和Semmle Python概念库模块
import python
import semmle.python.Concepts

// 从加密操作类中查找操作和算法
from Cryptography::CryptographicOperation cryptoOp, Cryptography::CryptographicAlgorithm cryptoAlgo
where
  // 条件1：算法是当前操作所使用的算法
  cryptoAlgo = cryptoOp.getAlgorithm() and
  (
    // 条件2：算法是哈希算法
    cryptoAlgo instanceof Cryptography::HashingAlgorithm or
    // 条件3：算法是密码哈希算法
    cryptoAlgo instanceof Cryptography::PasswordHashingAlgorithm
  )
// 选择操作并返回使用的算法名称
select cryptoOp, "Use of algorithm " + cryptoOp.getAlgorithm().getName()