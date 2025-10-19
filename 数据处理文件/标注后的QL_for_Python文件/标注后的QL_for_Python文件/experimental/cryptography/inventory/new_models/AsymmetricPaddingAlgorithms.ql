/**
 * @name Asymmetric Padding Schemes
 * @description Finds all potential usage of padding schemes used with asymmetric algorithms.
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python  // 导入Python库，用于分析Python代码
import experimental.cryptography.Concepts  // 导入实验性加密概念库，用于处理加密相关的概念

// 从AsymmetricPadding类中选择算法alg
from AsymmetricPadding alg

// 选择alg和使用alg的填充方案名称，并生成相应的描述信息
select alg, "Use of algorithm " + alg.getPaddingName()
