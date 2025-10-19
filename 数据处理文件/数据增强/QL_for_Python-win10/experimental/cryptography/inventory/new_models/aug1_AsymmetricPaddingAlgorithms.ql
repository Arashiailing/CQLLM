/**
 * @name Detection of Asymmetric Encryption Padding Techniques
 * @description Identifies all instances where padding schemes are employed in asymmetric cryptographic algorithms.
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python  // 导入Python库，用于分析Python代码
import experimental.cryptography.Concepts  // 导入实验性加密概念库，用于处理加密相关的概念

// 查询所有非对称加密填充方案
from AsymmetricPadding paddingScheme

// 输出填充方案对象及其描述信息
select paddingScheme, "Detected asymmetric padding scheme: " + paddingScheme.getPaddingName()