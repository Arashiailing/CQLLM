/**
 * @name All Cryptographic Algorithms
 * @description Finds all potential usage of cryptographic algorithms usage using the supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入Python库，用于分析Python代码
import python
// 导入实验性的加密概念库，用于识别加密算法
import experimental.cryptography.Concepts

// 从CryptographicAlgorithm类中选择所有实例alg
from CryptographicAlgorithm alg
// 选择alg并返回一个包含算法名称的字符串
select alg, "Use of algorithm " + alg.getName()
