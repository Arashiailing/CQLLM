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

/**
 * 将字典键表达式转换为规范字符串表示
 * @param dictionary 目标字典
 * @param keyExpression 字典中的键表达式
 * @param normalizedString 规范化后的字符串表示
 */
predicate normalize_key_representation(Dict dictionary, Expr keyExpression, string normalizedString) {
  // 确保keyExpression是字典中的键
  keyExpression = dictionary.getAKey() and
  (
    // 处理数值类型键：直接获取数值字符串
    normalizedString = keyExpression.(Num).getN()
    or
    // 处理字符串类型键：排除包含特殊字符的键
    not "�" = normalizedString.charAt(_) and
    // 区分Unicode和字节串字面量
    exists(StringLiteral strLiteral | 
      strLiteral = keyExpression and
      (
        normalizedString = "u\"" + strLiteral.getText() + "\"" and strLiteral.isUnicode()
        or
        normalizedString = "b\"" + strLiteral.getText() + "\"" and not strLiteral.isUnicode()
      )
    )
  )
}

// 查找字典中的重复键对
from Dict dictionary, Expr firstKeyExpr, Expr secondKeyExpr
where
  // 检查存在相同的规范化键字符串但表达式不同
  exists(string normalizedKeyString | 
    normalize_key_representation(dictionary, firstKeyExpr, normalizedKeyString) and 
    normalize_key_representation(dictionary, secondKeyExpr, normalizedKeyString) and 
    firstKeyExpr != secondKeyExpr
  ) and
  (
    // 情况1：同一基本块中的顺序覆盖
    exists(BasicBlock block, int firstIndex, int secondIndex |
      firstKeyExpr.getAFlowNode() = block.getNode(firstIndex) and
      secondKeyExpr.getAFlowNode() = block.getNode(secondIndex) and
      firstIndex < secondIndex
    )
    or
    // 情况2：跨基本块的控制流覆盖
    firstKeyExpr.getAFlowNode().getBasicBlock().strictlyDominates(
      secondKeyExpr.getAFlowNode().getBasicBlock()
    )
  )
// 输出重复键警告，标记覆盖位置
select firstKeyExpr, 
  "Dictionary key " + repr(firstKeyExpr) + " is subsequently $@.", 
  secondKeyExpr, 
  "overwritten"