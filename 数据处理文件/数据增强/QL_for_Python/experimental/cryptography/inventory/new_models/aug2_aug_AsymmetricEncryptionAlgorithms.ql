/**
 * @name 非对称加密算法检测
 * @description 识别代码中所有通过受支持库使用非对称密钥执行加密或密钥交换操作的位置。
 * @kind 问题
 * @id py/quantum-readiness/cbom/all-asymmetric-encryption-algorithms
 * @problem.severity 错误
 * @tags cbom
 *       密码学
 */

import python
import experimental.cryptography.Concepts

// 检索所有非对称加密算法的使用情况并生成安全警告信息
from AsymmetricEncryptionAlgorithm encryptionInstance
select encryptionInstance, "Use of algorithm " + encryptionInstance.getEncryptionName()