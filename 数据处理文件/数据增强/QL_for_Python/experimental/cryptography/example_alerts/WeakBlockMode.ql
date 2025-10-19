/**
 * @name Weak block mode
 * @description Finds uses of symmetric encryption block modes that are weak, obsolete, or otherwise unaccepted.
 * @id py/weak-block-mode
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// 从CryptographicArtifact中选择操作对象op和消息字符串msg
from CryptographicArtifact op, string msg
where
  // 排除误报，一些项目直接包含了所有的cryptography模块
  // 过滤掉任何匹配cryptography/hazmat路径的结果
  // 特别是ECB在keywrap操作内部被使用的情况
  not op.asExpr()
      .getLocation()
      .getFile()
      .getAbsolutePath()
      .toString()
      .matches("%cryptography/hazmat/%") and
  (
    // 如果op是BlockMode的实例
    op instanceof BlockMode and
    // ECB模式仅允许用于KeyWrapOperations，即仅在ECB不是KeyWrapOperation时报警
    (op.(BlockMode).getBlockModeName() = "ECB" implies not op instanceof KeyWrapOperation) and
    exists(string name | name = op.(BlockMode).getBlockModeName() |
      // 只允许CBC、CTS、XTS模式
      //  https://liquid.microsoft.com/Web/Object/Read/MS.Security/Requirements/Microsoft.Security.Cryptography.10002
      not name = ["CBC", "CTS", "XTS"] and
      if name = unknownAlgorithm()
      then msg = "Use of unrecognized block mode algorithm."
      else
        if name in ["GCM", "CCM"]
        then
          msg =
            "Use of block mode algorithm " + name +
              " requires special crypto board approval/review."
        else msg = "Use of unapproved block mode algorithm or API " + name + "."
    )
    or
    // 如果op是SymmetricCipher的实例且没有指定块模式算法
    op instanceof SymmetricCipher and
    not op.(SymmetricCipher).hasBlockMode() and
    msg = "Cipher has unspecified block mode algorithm."
  )
select op, msg
