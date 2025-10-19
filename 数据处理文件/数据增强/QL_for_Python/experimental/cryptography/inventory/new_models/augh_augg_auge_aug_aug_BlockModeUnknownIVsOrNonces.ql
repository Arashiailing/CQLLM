/**
 * @name 未配置初始化向量 (IV) 或 nonce 的块密码模式
 * @description 检测块密码加密实现中未正确设置初始化向量或nonce参数的情况。
 *              当这些参数使用默认值或源自不可信输入时，可能导致加密强度降低。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 识别所有块密码模式实例
from BlockMode insecureCipherMode

// 筛选条件：块密码模式实例缺少IV或nonce配置
// 这种配置缺失可能导致加密操作使用可预测或重复的初始化向量
where not insecureCipherMode.hasIVorNonce()

// 输出结果：展示存在安全风险的块密码模式实例及其问题描述
select insecureCipherMode, "Block mode with unknown IV or Nonce configuration"