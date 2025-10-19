/**
 * @name 未知初始化向量 (IV) 或 nonce
 * @description 识别块密码操作中使用的、来源不明的初始化向量 (IV) 或 nonce。
 *              这些参数对于加密安全性至关重要，未知来源可能导致加密弱点。
 * @kind problem
 * @id py/quantum-readiness/cbom/unkown-iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// 定义查询范围：所有块密码模式
from BlockMode blockCipherMode
// 过滤条件：块密码模式缺少 IV 或 nonce 配置
where not blockCipherMode.hasIVorNonce()
// 输出结果：匹配的块密码模式及其问题描述
select blockCipherMode, "Block mode with unknown IV or Nonce configuration"