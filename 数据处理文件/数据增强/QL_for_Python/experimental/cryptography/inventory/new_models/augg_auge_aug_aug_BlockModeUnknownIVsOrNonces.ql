/**
 * @name 未配置初始化向量 (IV) 或 nonce 的块密码模式
 * @description 识别块密码加密模式中未正确设置初始化向量或nonce参数的实例，
 *              这些参数若来源于不可信输入源可能导致安全漏洞
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 定义存在安全风险的块密码模式实例
// 这些实例未配置必要的IV或nonce参数，可能使用默认值或不可信输入
from BlockMode vulnerableBlockMode

// 筛选条件：块密码模式实例缺少IV或nonce配置
// 这种情况可能导致加密操作使用可预测或重复的初始化向量
where not vulnerableBlockMode.hasIVorNonce()

// 输出结果：显示存在安全风险的块密码模式实例及其问题描述
select vulnerableBlockMode, "Block mode with unknown IV or Nonce configuration"