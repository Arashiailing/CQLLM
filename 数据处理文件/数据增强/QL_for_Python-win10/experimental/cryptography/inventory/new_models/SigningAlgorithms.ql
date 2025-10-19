/**
 * @name Signing Algorithms
 * @description Finds all potential usage of signing algorithms using the supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/signing-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入Python库，用于分析Python代码
import python

// 导入实验性加密概念库，用于处理加密相关的概念和操作
import experimental.cryptography.Concepts

// 从SigningAlgorithm类中选择算法实例alg
from SigningAlgorithm alg

// 查询语句：选择alg以及使用alg.getName()方法获取的算法名称，并附加前缀"Use of algorithm "
select alg, "Use of algorithm " + alg.getName()
