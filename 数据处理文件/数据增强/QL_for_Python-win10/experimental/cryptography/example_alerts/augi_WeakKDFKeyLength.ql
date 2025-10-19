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

// 检测密钥派生函数中派生密钥长度不足的情况
from KeyDerivationOperation kdfOperation, string diagnosticMessage, DataFlow::Node keySizeOrigin
where
  // 获取密钥大小配置源节点，并排除显式设置为None的情况
  keySizeOrigin = kdfOperation.getDerivedKeySizeSrc() and
  not keySizeOrigin.asExpr() instanceof None and
  (
    // 情况1：密钥大小是整数字面量但小于16字节
    exists(int keyLength | keyLength = keySizeOrigin.asExpr().(IntegerLiteral).getValue() |
      keyLength < 16 and
      diagnosticMessage = "Derived key size is too small. "
    )
    or
    // 情况2：密钥大小无法静态验证（非整数字面量）
    not exists(keySizeOrigin.asExpr().(IntegerLiteral).getValue()) and
    diagnosticMessage = "Derived key size is not a statically verifiable size. "
  )
select kdfOperation, diagnosticMessage + "Derived key size must be a minimum of 16 (bytes). Derived Key Size Config: $@",
  keySizeOrigin.asExpr(), keySizeOrigin.asExpr().toString()