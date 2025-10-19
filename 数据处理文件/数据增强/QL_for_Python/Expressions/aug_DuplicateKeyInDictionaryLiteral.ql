/**
 * @name Duplicate key in dict literal
 * @description Detects duplicate keys in dictionary literals where all but the last occurrence are lost
 * @kind problem
 * @tags reliability
 *       useless-code
 *       external/cwe/cwe-561
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/duplicate-key-dict-literal
 */

import python
import semmle.python.strings

// 定义谓词：将字典键表达式转换为规范字符串表示
predicate key_to_string(Dict dict, Expr keyExpr, string normalizedStr) {
  // 检查keyExpr是否是字典中的键
  keyExpr = dict.getAKey() and
  (
    // 数值键：直接获取数值作为字符串表示
    normalizedStr = keyExpr.(Num).getN()
    or
    // 处理非特殊字符的字符串键
    not "�" = normalizedStr.charAt(_) and
    // 处理字符串字面量（区分Unicode和字节串）
    exists(StringLiteral strLit | strLit = keyExpr |
      normalizedStr = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
      or
      normalizedStr = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
    )
  )
}

// 查找字典中的重复键对
from Dict dict, Expr firstKey, Expr secondKey
where
  // 存在相同的规范化字符串表示，但表达式不同
  exists(string normalizedKeyStr | 
    key_to_string(dict, firstKey, normalizedKeyStr) and 
    key_to_string(dict, secondKey, normalizedKeyStr) and 
    firstKey != secondKey
  ) and
  (
    // 情况1：两个键位于同一基本块且firstKey在secondKey之前
    exists(BasicBlock containingBlock, int firstPos, int secondPos |
      firstKey.getAFlowNode() = containingBlock.getNode(firstPos) and
      secondKey.getAFlowNode() = containingBlock.getNode(secondPos) and
      firstPos < secondPos
    )
    or
    // 情况2：firstKey的基本块严格支配secondKey的基本块
    firstKey.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKey.getAFlowNode().getBasicBlock()
    )
  )
// 输出重复键警告，标记覆盖位置
select firstKey, 
  "Dictionary key " + repr(firstKey) + " is subsequently $@.", 
  secondKey, 
  "overwritten"