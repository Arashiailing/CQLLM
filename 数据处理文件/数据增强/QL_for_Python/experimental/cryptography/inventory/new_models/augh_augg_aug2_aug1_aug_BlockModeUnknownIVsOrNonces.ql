/**
 * @name 未配置的初始化向量 (IV) 或 nonce
 * @description 识别在块密码加密操作中未正确配置初始化向量或nonce参数的实例。
 *              当这些关键加密参数来源不可信或缺失时，可能引发严重的安全隐患。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 获取所有块密码加密模式实例
from BlockMode blockCipherMode

// 安全性验证：检查加密操作是否缺少必要的IV或nonce配置
// 这些参数对于确保加密强度至关重要，缺失会导致加密过程易受攻击
where 
  // 确定当前加密模式是否未配置IV或nonce
  not blockCipherMode.hasIVorNonce()

// 生成检测结果：标记存在安全风险的加密模式实例
select blockCipherMode, "Block mode with unknown IV or Nonce configuration"