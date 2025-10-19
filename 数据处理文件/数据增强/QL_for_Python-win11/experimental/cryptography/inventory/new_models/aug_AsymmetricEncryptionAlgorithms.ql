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

// 检索所有非对称加密算法实例并生成相应的警告信息
from AsymmetricEncryptionAlgorithm cryptoAlgorithm
select cryptoAlgorithm, "Use of algorithm " + cryptoAlgorithm.getEncryptionName()