/**
 * @name All Cryptographic Algorithms
 * @description Finds all potential usage of cryptographic algorithms usage using the supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入Python分析框架，提供Python代码解析和分析能力
import python
// 导入加密算法概念库，包含加密算法的抽象定义和识别方法
import experimental.cryptography.Concepts

// 查询所有已识别的加密算法实例
from CryptographicAlgorithm cryptoAlgo
// 返回加密算法对象及其使用描述
select cryptoAlgo, "Use of algorithm " + cryptoAlgo.getName()