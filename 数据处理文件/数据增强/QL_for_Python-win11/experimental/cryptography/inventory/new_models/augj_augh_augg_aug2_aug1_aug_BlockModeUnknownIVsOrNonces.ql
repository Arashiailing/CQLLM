/**
 * @name 未配置的初始化向量 (IV) 或 nonce
 * @description 检测在块密码加密操作中未正确配置初始化向量或nonce参数的实例。
 *              这些参数对于加密算法的安全性至关重要，当它们缺失或来源不可信时，
 *              可能导致加密过程容易被破解，造成敏感数据泄露。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 定义查询范围：识别所有块密码加密模式实例
from BlockMode unconfiguredBlockMode

// 安全性检查：验证加密操作是否配置了必要的IV或nonce参数
// IV(初始化向量)和nonce(仅使用一次的数字)是块密码算法的关键安全参数，
// 它们的缺失会显著降低加密强度，使加密数据容易受到各种攻击
where 
  // 筛选条件：确定当前加密模式是否未配置IV或nonce
  // 这是检测加密配置安全性的核心条件
  not unconfiguredBlockMode.hasIVorNonce()

// 输出结果：标记所有存在安全风险的加密模式实例
// 提供明确的警告信息，指出这些实例缺少必要的安全配置
select unconfiguredBlockMode, "Block mode with unknown IV or Nonce configuration"