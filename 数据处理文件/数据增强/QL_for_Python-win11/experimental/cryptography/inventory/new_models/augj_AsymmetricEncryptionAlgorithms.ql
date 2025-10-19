/**
 * @name 非对称加密算法检测
 * @description 识别代码库中所有使用受支持库的非对称密钥进行加密或密钥交换的潜在用法。
 * @kind 问题
 * @id py/quantum-readiness/cbom/all-asymmetric-encryption-algorithms
 * @problem.severity 错误
 * @tags cbom
 *       密码学
 */

import python
import experimental.cryptography.Concepts

// 查询所有非对称加密算法实例
from AsymmetricEncryptionAlgorithm asymmetricCipher

// 构造结果消息，标识检测到的算法使用情况
select asymmetricCipher, 
       "检测到使用非对称加密算法: " + asymmetricCipher.getEncryptionName()