/**
 * @name Initialization Vector (IV) or nonces
 * @description Identifies potential sources of initialization vectors (IV) or nonce values 
 *              utilized in block cipher operations across supported cryptographic libraries.
 *              This query helps in identifying potential cryptographic weaknesses related to
 *              IV/nonce management in block cipher modes of operation.
 * @kind problem
 * @id py/quantum-readiness/cbom/iv-sources
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python // 导入Python语言库，用于分析Python代码
import experimental.cryptography.Concepts // 导入实验性加密概念库，用于处理加密相关的概念和模式

// 查找所有块密码模式中使用的初始化向量(IV)或随机数(nonce)的来源表达式
from BlockMode encryptionMode, Expr ivOrNonceExpr
where ivOrNonceExpr = encryptionMode.getIVorNonce().asExpr()
select ivOrNonceExpr, "Block mode IV/Nonce source"