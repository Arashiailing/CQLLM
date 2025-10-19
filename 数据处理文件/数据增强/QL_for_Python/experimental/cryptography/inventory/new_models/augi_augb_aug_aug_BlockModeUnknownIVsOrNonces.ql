/**
 * @name 未配置初始化向量 (IV) 或 nonce
 * @description 识别块密码操作中缺少初始化向量或nonce配置的代码点，这些参数可能源自不可信输入源
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 安全分析目标：识别所有使用块密码加密模式的代码位置
// 此类代码在IV或nonce未正确设置时可能引入严重安全漏洞
from BlockMode vulnerableBlockMode
where 
    // 过滤条件：验证块密码模式是否缺少必要的IV或nonce配置
    // 缺少这些关键参数可能导致加密强度降低，使系统易受密码分析攻击
    exists(vulnerableBlockMode) and
    not vulnerableBlockMode.hasIVorNonce()
select 
    // 报告结果：标记存在安全风险的块密码模式实例
    vulnerableBlockMode, 
    // 提供安全问题描述
    "Block mode with unknown IV or Nonce configuration"