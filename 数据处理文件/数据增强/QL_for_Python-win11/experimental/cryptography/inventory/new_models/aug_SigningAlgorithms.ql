/**
 * @name Signing Algorithms
 * @description Finds all potential usage of signing algorithms using the supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/signing-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 引入Python语言分析支持库
import python

// 加载加密概念相关实验性模块，用于识别加密操作和算法
import experimental.cryptography.Concepts

// 定义变量，表示签名算法实例
from SigningAlgorithm cryptoSigningAlgorithm

// 输出结果：签名算法实例及其描述信息
select cryptoSigningAlgorithm, "Use of algorithm " + cryptoSigningAlgorithm.getName()