/**
 * @name 非对称加密算法检测
 * @description 识别所有使用受支持库中非对称密钥进行加密或密钥交换的潜在用法
 * @kind 问题
 * @id py/quantum-readiness/cbom/all-asymmetric-encryption-algorithms
 * @problem.severity 错误
 * @tags cbom
 *       密码学
 */

import python
import experimental.cryptography.Concepts

// 查询所有非对称加密算法实例
from AsymmetricEncryptionAlgorithm asymmetricCrypto
// 生成包含算法名称的描述信息
select 
  asymmetricCrypto,
  "Use of algorithm " + asymmetricCrypto.getEncryptionName()