/**
 * @name Weak block mode
 * @description Identifies symmetric encryption block modes that are considered weak, obsolete, or otherwise not approved for use.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// 选择加密构件cryptoArtifact和对应的警告消息alertMessage
from CryptographicArtifact cryptoArtifact, string alertMessage
where
  // 排除误报情况：过滤掉位于cryptography/hazmat路径下的代码
  // 特别是ECB在keywrap操作内部被使用的情况
  not cryptoArtifact.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // 检查加密构件是否为块模式实例
    cryptoArtifact instanceof BlockMode and
    // ECB模式仅允许用于密钥包装操作，其他情况视为不安全
    (cryptoArtifact.(BlockMode).getBlockModeName() = "ECB" implies not cryptoArtifact instanceof KeyWrapOperation) and
    exists(string modeName | modeName = cryptoArtifact.(BlockMode).getBlockModeName() |
      // 仅允许CBC、CTS、XTS这三种块模式
      // 参考：https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not modeName = ["CBC", "CTS", "XTS"] and
      if modeName = unknownAlgorithm()
      then alertMessage = "Use of unrecognized block mode algorithm."
      else
        if modeName in ["GCM", "CCM"]
        then
          alertMessage =
            "Use of block mode algorithm " + modeName +
              " requires special crypto board approval/review."
        else alertMessage = "Use of unapproved block mode algorithm or API " + modeName + "."
    )
    or
    // 检查加密构件是否为对称密码实例且未指定块模式算法
    cryptoArtifact instanceof SymmetricCipher and
    not cryptoArtifact.(SymmetricCipher).hasBlockMode() and
    alertMessage = "Cipher has unspecified block mode algorithm."
  )
select cryptoArtifact, alertMessage