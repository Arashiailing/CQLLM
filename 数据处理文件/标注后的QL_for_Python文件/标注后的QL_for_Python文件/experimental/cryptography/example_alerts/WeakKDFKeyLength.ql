/**
 * @name Small KDF derived key length.
 * @description KDF derived keys should be a minimum of 128 bits (16 bytes).
 * @assumption If the key length is not explicitly provided (e.g., it is None or otherwise not specified) assumes the length is derived from the hash length.
 * @kind problem
 * @id py/kdf-small-key-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// 从 KeyDerivationOperation 操作中获取派生密钥大小来源，并检查其是否小于 16 字节。
from KeyDerivationOperation op, string msg, DataFlow::Node derivedKeySizeSrc
where
  // 假设：如果未指定密钥大小或显式为 None，则通常密钥大小是从所使用的哈希算法中派生的。
  // 目前可接受的哈希算法有 "SHA256", "SHA384", "SHA512"，这些算法生成的哈希值长度都足够大。
  // 我们将依赖其他可接受的哈希查询来确定在未指定密钥大小时，密钥大小是否足够。
  derivedKeySizeSrc = op.getDerivedKeySizeSrc() and
  not derivedKeySizeSrc.asExpr() instanceof None and
  (
    // 如果派生密钥大小是整数字面量且小于 16，则报告错误消息。
    exists(derivedKeySizeSrc.asExpr().(IntegerLiteral).getValue()) and
    derivedKeySizeSrc.asExpr().(IntegerLiteral).getValue() < 16 and
    msg = "Derived key size is too small. "
    or
    // 如果派生密钥大小不是静态可验证的大小（即不是整数字面量），则报告错误消息。
    not exists(derivedKeySizeSrc.asExpr().(IntegerLiteral).getValue()) and
    msg = "Derived key size is not a statically verifiable size. "
  )
select op, msg + "Derived key size must be a minimum of 16 (bytes). Derived Key Size Config: $@",
  derivedKeySizeSrc.asExpr(), derivedKeySizeSrc.asExpr().toString()
