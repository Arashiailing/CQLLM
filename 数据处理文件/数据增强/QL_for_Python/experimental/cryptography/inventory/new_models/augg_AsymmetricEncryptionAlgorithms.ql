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

// 定义变量存储非对称加密算法实例
from AsymmetricEncryptionAlgorithm cryptoAlgorithm
// 构建结果消息并选择算法实例与描述信息
select cryptoAlgorithm, "Use of algorithm " + cryptoAlgorithm.getEncryptionName()