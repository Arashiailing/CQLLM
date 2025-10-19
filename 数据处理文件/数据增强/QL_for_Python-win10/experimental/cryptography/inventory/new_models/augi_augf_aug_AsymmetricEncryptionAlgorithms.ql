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

// 此查询旨在检测代码库中使用的所有非对称加密算法实例
// 非对称加密算法在量子计算时代可能面临安全风险，因此需要特别关注
// 这些算法通常用于密钥交换、数字签名和加密操作
from AsymmetricEncryptionAlgorithm asymmetricCryptoAlgorithm
// 获取算法名称以便在结果中显示
where exists(asymmetricCryptoAlgorithm.getEncryptionName())
// 输出检测到的非对称加密算法实例及其名称信息
select asymmetricCryptoAlgorithm, "Use of algorithm " + asymmetricCryptoAlgorithm.getEncryptionName()