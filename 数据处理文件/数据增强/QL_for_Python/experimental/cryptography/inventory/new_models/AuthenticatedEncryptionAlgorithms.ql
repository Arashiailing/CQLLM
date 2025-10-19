/**
 * @name Authenticated Encryption Algorithms
 * @description Finds all potential usage of authenticated encryption schemes using the supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/authenticated-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入Python库，用于分析Python代码
import python

// 导入实验性加密概念库，用于处理加密相关的概念和算法
import experimental.cryptography.Concepts

// 从AuthenticatedEncryptionAlgorithm类中选择所有实例
from AuthenticatedEncryptionAlgorithm alg

// 查询语句：选择算法实例和其对应的认证加密名称，并生成警告信息
select alg, "Use of algorithm " + alg.getAuthticatedEncryptionName()
