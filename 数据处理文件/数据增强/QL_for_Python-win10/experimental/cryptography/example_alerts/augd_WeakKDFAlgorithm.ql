/**
 * @name Weak KDF algorithm.
 * @description Detects the use of unapproved key derivation function (KDF) algorithms.
 * Approved KDF algorithms must be one of the following:
 * ["PBKDF2", "PBKDF2HMAC", "KBKDF", "KBKDFHMAC", "CONCATKDF", "CONCATKDFHASH"]
 * @assumption The value being used to derive a key (either a key or a password) is correct for the algorithm (i.e., a key is used for KBKDF and a password for PBKDF).
 * @kind problem
 * @id py/weak-kdf-algorithm
 * @problem.severity error
 * @precision high
 */

import python  // 导入Python库，用于分析Python代码
import experimental.cryptography.Concepts  // 导入实验性加密概念库，用于处理加密相关的概念和操作

// 定义批准的KDF算法集合
// 这些算法被认为是安全的密钥派生函数
from KeyDerivationAlgorithm kdfOperation
where
  not kdfOperation.getKDFName() = [
    "PBKDF2", "PBKDF2HMAC", "KBKDF", "KBKDFHMAC", "KBKDFCMAC", "CONCATKDF", "CONCATKDFHASH",
    "CONCATKDFHMAC"
  ]
select kdfOperation, "Use of unapproved, weak, or unknown key derivation algorithm or API."  // 选择使用了未经批准、弱或未知的密钥派生函数算法或API的操作