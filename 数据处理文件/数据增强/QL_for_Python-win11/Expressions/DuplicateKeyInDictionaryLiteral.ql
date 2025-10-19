/**
 * @name Duplicate key in dict literal
 * @description Duplicate key in dict literal. All but the last will be lost.
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

// 定义一个谓词函数，用于判断字典中的键是否满足特定条件
predicate dict_key(Dict d, Expr k, string s) {
  // 检查表达式k是否是字典d的一个键
  k = d.getAKey() and
  (
    // 如果k是一个数字类型，则获取其数值并赋值给字符串s
    s = k.(Num).getN()
    or
    // 我们使用�来标记不可表示的字符，因此两个�实例可能代表源文件中不同的字符串
    not "�" = s.charAt(_) and
    // 检查是否存在一个字符串字面量c，使得c等于k，并且根据是否为Unicode编码设置s的值
    exists(StringLiteral c | c = k |
      s = "u\"" + c.getText() + "\"" and c.isUnicode()
      or
      s = "b\"" + c.getText() + "\"" and not c.isUnicode()
    )
  )
}

// 从字典d中选择两个表达式k1和k2，这两个表达式是字典中的键
from Dict d, Expr k1, Expr k2
where
  // 存在一个字符串s，使得k1和k2都是字典d的键，并且k1不等于k2
  exists(string s | dict_key(d, k1, s) and dict_key(d, k2, s) and k1 != k2) and
  (
    // 存在一个基本块b和两个整数i1、i2，使得k1和k2分别位于该基本块的第i1和第i2个节点，并且i1小于i2
    exists(BasicBlock b, int i1, int i2 |
      k1.getAFlowNode() = b.getNode(i1) and
      k2.getAFlowNode() = b.getNode(i2) and
      i1 < i2
    )
    or
    // 或者k1所在的基本块严格支配k2所在的基本块
    k1.getAFlowNode().getBasicBlock().strictlyDominates(k2.getAFlowNode().getBasicBlock())
  )
// 选择k1和k2，并生成相应的警告信息，指出字典键k1随后被k2覆盖
select k1, "Dictionary key " + repr(k1) + " is subsequently $@.", k2, "overwritten"
