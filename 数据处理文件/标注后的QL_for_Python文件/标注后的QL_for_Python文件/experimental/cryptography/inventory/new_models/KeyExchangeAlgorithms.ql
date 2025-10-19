/**
 * @name Key Exchange Algorithms
 * @description Finds all potential usage of key exchange using the supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/key-exchange
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入Python库，用于分析Python代码
import python

// 导入实验性的加密概念库，用于处理加密相关的概念和算法
import experimental.cryptography.Concepts

// 从KeyExchangeAlgorithm类中选择算法alg
from KeyExchangeAlgorithm alg

// 查询语句：选择算法alg，并返回一个字符串，表示使用了哪个算法
select alg, "Use of algorithm " + alg.getName()
