/**
 * @name 非对称加密算法
 * @description 检测代码中所有使用受支持库的非对称密钥进行加密或密钥交换的潜在用法。
 * @kind 问题
 * @id py/quantum-readiness/cbom/all-asymmetric-encryption-algorithms
 * @problem.severity 错误
 * @tags cbom
 *       密码学
 */

import python
import experimental.cryptography.Concepts

// 查询所有非对称加密算法实例
// 为每个算法生成一条警告，指出其使用情况
from AsymmetricEncryptionAlgorithm asymmetricAlgorithm
select asymmetricAlgorithm, "Use of algorithm " + asymmetricAlgorithm.getEncryptionName()