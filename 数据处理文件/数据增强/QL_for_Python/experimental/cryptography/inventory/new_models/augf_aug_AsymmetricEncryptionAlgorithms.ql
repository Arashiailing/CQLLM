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

// 本查询旨在识别代码中使用的所有非对称加密算法实例
// 这些算法可能面临量子计算威胁，需要被标记和审查
from AsymmetricEncryptionAlgorithm asymmetricEncryptionInstance
select asymmetricEncryptionInstance, "Use of algorithm " + asymmetricEncryptionInstance.getEncryptionName()