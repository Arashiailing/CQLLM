/**
 * @name 非对称加密算法使用检测
 * @description 检测代码中使用了潜在非对称密钥进行加密或密钥交换操作的位置，这些操作可能受到量子计算威胁。
 * @kind 问题
 * @id py/quantum-readiness/cbom/all-asymmetric-encryption-algorithms
 * @problem.severity 错误
 * @tags cbom
 *       密码学
 *       量子安全
 */

import python
import experimental.cryptography.Concepts

// 查找所有非对称加密算法实例并生成警告
from AsymmetricEncryptionAlgorithm nonSymmetricEncryption
select nonSymmetricEncryption, "Use of asymmetric encryption algorithm: " + nonSymmetricEncryption.getEncryptionName()