/**
 * @name Block cipher mode of operation
 * @description Finds all potential block cipher modes of operations using the supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/block-cipher-mode
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入Python库，用于分析Python代码
import python

// 导入实验性加密概念库，用于处理加密相关的概念和操作
import experimental.cryptography.Concepts

// 从BlockMode类中选择算法（alg）
from BlockMode alg

// 查询语句：选择算法（alg）并返回算法名称和使用信息
select alg, "Use of algorithm " + alg.getBlockModeName()
