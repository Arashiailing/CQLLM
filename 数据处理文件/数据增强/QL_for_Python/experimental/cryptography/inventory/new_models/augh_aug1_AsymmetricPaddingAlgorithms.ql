/**
 * @name Asymmetric Encryption Padding Schemes Detection
 * @description This query identifies all occurrences of padding schemes used in asymmetric cryptographic algorithms.
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// 导入必要的库
import python  // 用于Python代码分析
import experimental.cryptography.Concepts  // 提供加密相关概念支持

// 查询并输出所有非对称加密填充方案
from AsymmetricPadding asymmetricPadding
select asymmetricPadding, "Detected asymmetric padding scheme: " + asymmetricPadding.getPaddingName()