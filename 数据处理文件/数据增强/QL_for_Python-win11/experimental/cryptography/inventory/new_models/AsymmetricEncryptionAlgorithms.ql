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

// 从 AsymmetricEncryptionAlgorithm 类中选择算法实例 alg
from AsymmetricEncryptionAlgorithm alg
// 选择 alg 和 "Use of algorithm " + alg.getEncryptionName() 作为查询结果
select alg, "Use of algorithm " + alg.getEncryptionName()
