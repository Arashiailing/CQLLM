/**
 * @name Detection of Asymmetric Encryption Padding Techniques
 * @description Identifies all instances where padding schemes are employed in asymmetric cryptographic algorithms.
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python  // 导入Python分析库，用于处理Python代码分析
import experimental.cryptography.Concepts  // 导入实验性加密概念库，提供加密相关抽象定义

// 查找所有非对称加密算法中使用的填充方案
from AsymmetricPadding asymmetricPadding

// 输出检测到的填充方案及其名称信息
select asymmetricPadding, "Detected asymmetric padding scheme: " + asymmetricPadding.getPaddingName()