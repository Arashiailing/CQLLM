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

// 检索代码中使用的所有对称填充方案
from SymmetricPadding paddingScheme

// 生成查询结果，包括填充方案对象和描述性消息
select paddingScheme, "Use of algorithm " + paddingScheme.getPaddingName()