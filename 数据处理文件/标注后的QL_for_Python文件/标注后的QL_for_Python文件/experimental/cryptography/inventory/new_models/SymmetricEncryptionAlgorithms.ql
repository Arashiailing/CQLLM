/**
 * @name Symmetric Encryption Algorithms
 * @description Finds all potential usage of symmetric encryption algorithms using the supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python  # 导入Python库，用于分析Python代码
import experimental.cryptography.Concepts  # 导入实验性加密概念库，用于识别加密算法

# 从SymmetricEncryptionAlgorithm类中选择所有实例alg
from SymmetricEncryptionAlgorithm alg

# 查询语句：选择alg和"Use of algorithm " + alg.getEncryptionName()
select alg, "Use of algorithm " + alg.getEncryptionName()
