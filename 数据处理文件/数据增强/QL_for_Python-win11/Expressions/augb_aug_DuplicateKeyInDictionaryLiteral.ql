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
 * @id py/duplicate-key-dict-literal */

import python
import semmle.python.strings

// 定义谓词：将字典键表达式转换为规范字符串表示
// 此谓词用于比较字典中的键是否相同，通过将键转换为规范的字符串表示形式
// 支持数值键和字符串键（包括Unicode和字节串）
predicate key_to_normalized_representation(Dict dict, Expr keyExpr, string normalizedKey) {
  // 检查keyExpr是否是字典中的键
  keyExpr = dict.getAKey() and
  (
    // 数值键：直接获取数值作为字符串表示
    // 例如：数字42会被转换为字符串"42"
    normalizedKey = keyExpr.(Num).getN()
    or
    // 处理字符串键（包括Unicode和字节串）
    // Unicode字符串会被添加"u"前缀，例如：u"hello"
    // 字节串会被添加"b"前缀，例如：b"hello"
    exists(StringLiteral strLit | strLit = keyExpr |
      normalizedKey = "u\"" + strLit.getText() + "\"" and strLit.isUnicode()
      or
      normalizedKey = "b\"" + strLit.getText() + "\"" and not strLit.isUnicode()
    ) and
    // 确保字符串不包含特殊字符，以避免比较问题
    not "�" = normalizedKey.charAt(_)
  )
}

// 查找字典中的重复键对
// 此查询会检测字典字面量中的重复键，其中除了最后一次出现的键外，其他所有重复键都会被覆盖
from Dict dict, Expr initialKey, Expr subsequentKey
where
  // 存在相同的规范化字符串表示，但表达式不同
  // 这表示两个键在逻辑上是相同的，但在代码中是不同的表达式
  exists(string normalizedKeyRepresentation | 
    key_to_normalized_representation(dict, initialKey, normalizedKeyRepresentation) and 
    key_to_normalized_representation(dict, subsequentKey, normalizedKeyRepresentation) and 
    initialKey != subsequentKey
  ) and
  (
    // 情况1：两个键位于同一基本块且initialKey在subsequentKey之前
    // 这种情况下，initialKey会被subsequentKey覆盖
    exists(BasicBlock commonBlock, int initialPosition, int subsequentPosition |
      initialKey.getAFlowNode() = commonBlock.getNode(initialPosition) and
      subsequentKey.getAFlowNode() = commonBlock.getNode(subsequentPosition) and
      initialPosition < subsequentPosition
    )
    or
    // 情况2：initialKey的基本块严格支配subsequentKey的基本块
    // 这种情况下，initialKey在控制流上先于subsequentKey，因此会被覆盖
    initialKey.getAFlowNode().getBasicBlock().strictlyDominates(
      subsequentKey.getAFlowNode().getBasicBlock()
    )
  )
// 输出重复键警告，标记覆盖位置
// 消息格式：Dictionary key [initialKey] is subsequently [overwritten by subsequentKey]
select initialKey, 
  "Dictionary key " + repr(initialKey) + " is subsequently $@.", 
  subsequentKey, 
  "overwritten"