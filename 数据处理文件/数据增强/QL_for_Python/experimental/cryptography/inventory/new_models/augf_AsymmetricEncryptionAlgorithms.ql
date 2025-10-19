/**
 * @name 非对称加密算法
 * @description 查找所有使用受支持库的潜在非对称密钥进行加密或密钥交换的用法。
 * @kind 问题
 * @id py/quantum-readiness/cbom/all-asymmetric-encryption-algorithms
 * @problem.severity 错误
 * @tags cbom
 *       密码学
 */

import python
import experimental.cryptography.Concepts

// 查找所有非对称加密算法实例
from AsymmetricEncryptionAlgorithm cryptoAlgorithm
// 生成警告消息，标识检测到的非对称加密算法
select cryptoAlgorithm, "Use of algorithm " + cryptoAlgorithm.getEncryptionName()