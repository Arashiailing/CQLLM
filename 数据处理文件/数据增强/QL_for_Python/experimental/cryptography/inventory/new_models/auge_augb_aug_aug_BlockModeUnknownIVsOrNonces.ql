/**
 * @name 未知初始化向量 (IV) 或 nonce
 * @description 识别块密码操作中缺少初始化向量或nonce配置的安全隐患
 * @description 此类配置缺陷可能导致加密强度降低，使系统易受密码分析攻击
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 安全分析目标：检测所有使用块密码模式的加密操作
// 重点识别那些未正确配置关键安全参数(IV/nonce)的实例
from BlockMode vulnerableBlockMode
where 
    // 安全条件检查：验证块密码模式是否缺少必要的初始化向量或nonce配置
    // 缺少这些参数会显著降低加密安全性，可能导致可预测的加密输出
    not vulnerableBlockMode.hasIVorNonce()
select 
    // 分析结果：返回存在安全风险的块模式实例及其位置信息
    vulnerableBlockMode, 
    // 风险描述：明确指出检测到的安全问题类型
    "Block mode with unknown IV or Nonce configuration"