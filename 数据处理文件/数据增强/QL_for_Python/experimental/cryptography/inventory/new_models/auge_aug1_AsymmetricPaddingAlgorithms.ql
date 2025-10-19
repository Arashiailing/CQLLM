/**
 * @name Identification of Asymmetric Cryptographic Padding Methods
 * @description Detects and reports all occurrences of padding techniques used within asymmetric encryption algorithms.
 * @kind problem
 * @id py/quantum-readiness/cbom/asymmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python  // 导入Python库，用于分析Python代码
import experimental.cryptography.Concepts  // 导入实验性加密概念库，用于处理加密相关的概念

// 查询所有非对称加密填充方案实例
from AsymmetricPadding cryptoPadding

// 输出填充方案对象及其描述信息
select cryptoPadding, "Identified asymmetric padding method: " + cryptoPadding.getPaddingName()