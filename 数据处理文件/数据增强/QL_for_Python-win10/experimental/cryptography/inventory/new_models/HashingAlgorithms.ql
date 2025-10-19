/**
 * @name Hash Algorithms
 * @description Finds all potential usage of cryptographic hash algorithms using the supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入Python库，用于解析Python代码
import python

// 导入实验性加密概念库，用于识别加密算法
import experimental.cryptography.Concepts

// 从HashAlgorithm类中选择算法实例
from HashAlgorithm alg

// 查询语句：选择算法实例和其名称，并生成描述信息
select alg, "Use of algorithm " + alg.getName()
