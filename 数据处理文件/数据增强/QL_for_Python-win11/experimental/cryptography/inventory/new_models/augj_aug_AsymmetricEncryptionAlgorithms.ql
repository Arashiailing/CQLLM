/**
 * @name 非对称加密算法检测
 * @description 识别所有通过受支持库使用潜在非对称密钥执行加密或密钥交换操作的代码位置。
 * @kind 问题
 * @id py/quantum-readiness/cbom/all-asymmetric-encryption-algorithms
 * @problem.severity 错误
 * @tags cbom
 *       密码学
 */

import python
import experimental.cryptography.Concepts

// 查找代码中所有使用非对称加密算法的位置
// 这些算法通常涉及公钥/私钥对进行加密操作或密钥交换
from AsymmetricEncryptionAlgorithm nonSymmetricCryptoAlgo
select nonSymmetricCryptoAlgo, "检测到使用非对称加密算法: " + nonSymmetricCryptoAlgo.getEncryptionName()