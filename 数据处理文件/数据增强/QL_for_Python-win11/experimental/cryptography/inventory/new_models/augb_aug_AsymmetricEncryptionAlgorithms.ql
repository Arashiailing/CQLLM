/**
 * @name 非对称加密算法检测
 * @description 识别代码中所有使用非对称加密算法执行加密或密钥交换操作的位置。
 *              这些算法可能在未来量子计算环境中变得不安全。
 * @kind 问题
 * @id py/quantum-readiness/cbom/all-asymmetric-encryption-algorithms
 * @problem.severity 错误
 * @tags cbom
 *       密码学
 */

import python
import experimental.cryptography.Concepts

// 查询所有非对称加密算法的使用实例，并生成相应的安全警告
from AsymmetricEncryptionAlgorithm asymmetricCryptoInstance
select asymmetricCryptoInstance, "检测到使用非对称加密算法: " + asymmetricCryptoInstance.getEncryptionName()