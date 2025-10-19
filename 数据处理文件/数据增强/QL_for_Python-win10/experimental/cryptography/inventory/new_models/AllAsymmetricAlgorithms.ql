/**
 * @name All Asymmetric Algorithms
 * @description Finds all potential usage of asymmetric keys (RSA & ECC) using the supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-asymmetric-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入Python库，用于解析Python代码
import python

// 导入实验性的加密概念库，用于处理加密相关的查询
import experimental.cryptography.Concepts

// 从AsymmetricAlgorithm类中选择算法实例
from AsymmetricAlgorithm alg

// 选择算法实例和描述信息，描述信息包括算法名称
select alg, "Use of algorithm " + alg.getName()
