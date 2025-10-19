/**
 * @name 非对称加密算法检测
 * @description 识别代码中使用非对称加密算法的所有位置。这些算法在量子计算时代可能变得不安全，
 *               本查询旨在标记所有通过受支持库执行非对称加密或密钥交换操作的代码位置，
 *               以评估代码的量子就绪状态。
 * @kind 问题
 * @id py/quantum-readiness/cbom/all-asymmetric-encryption-algorithms
 * @problem.severity 错误
 * @tags cbom
 *       密码学
 */

import python
import experimental.cryptography.Concepts

// 检测所有非对称加密算法实例并提取算法名称
from AsymmetricEncryptionAlgorithm cryptoOperation, string algorithmName
where algorithmName = cryptoOperation.getEncryptionName()

// 生成包含算法名称的警告信息
select cryptoOperation, "Detected use of quantum-vulnerable algorithm: " + algorithmName