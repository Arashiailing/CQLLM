/**
 * @name Symmetric Padding Schemes
 * @description Finds all potential usage of padding schemes used with symmetric algorithms.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python // 导入python库，用于分析Python代码
import experimental.cryptography.Concepts // 导入实验性加密概念库，用于处理加密相关的概念

// 从SymmetricPadding类中选择算法alg
from SymmetricPadding alg
// 选择alg和使用alg的填充名称的组合
select alg, "Use of algorithm " + alg.getPaddingName()
