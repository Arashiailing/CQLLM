/**
 * @name Variable defined multiple times
 * @description Assignment to a variable occurs multiple times without any intermediate use of that variable
 * @kind problem
 * @tags maintainability
 *       useless-code
 *       external/cwe/cwe-563
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/multiple-definition
 */

import python
import Definition

// 定义一个谓词，用于检测变量是否被多次定义
predicate multiply_defined(AstNode asgn1, AstNode asgn2, Variable v) {
  /*
   * 必须在原始源对应的CFG中的所有可能路径上重新定义。
   * 例如，拆分可能会创建一个路径，其中`def`无条件地重新定义，即使它不在原始源中。
   */

  // 使用forex表达式遍历所有可能的定义和重定义节点
  forex(Definition def, Definition redef |
    def.getVariable() = v and // 获取变量v的定义节点
    def = asgn1.getAFlowNode() and // 将第一个赋值节点作为定义节点
    redef = asgn2.getAFlowNode() // 将第二个赋值节点作为重定义节点
  |
    def.isUnused() and // 检查定义节点是否未被使用
    def.getARedef() = redef and // 检查定义节点的重定义节点是否为第二个赋值节点
    def.isRelevant() // 检查定义节点是否相关
  )
}

// 定义一个谓词，用于检测表达式是否为简单字面量
predicate simple_literal(Expr e) {
  e.(Num).getN() = "0" // 检查数字字面量是否为0
  or
  e instanceof NameConstant // 检查是否为命名常量（如None）
  or
  e instanceof List and not exists(e.(List).getAnElt()) // 检查是否为空列表
  or
  e instanceof Tuple and not exists(e.(Tuple).getAnElt()) // 检查是否为空元组
  or
  e instanceof Dict and not exists(e.(Dict).getAKey()) // 检查是否为空字典
  or
  e.(StringLiteral).getText() = "" // 检查字符串字面量是否为空字符串
}

/**
 * Holds if the redefinition is uninteresting.
 *
 * A multiple definition is 'uninteresting' if it sets a variable to a
 * simple literal before reassigning it.
 * x = None
 * if cond:
 *     x = value1
 * else:
 *     x = value2
 */
// 定义一个谓词，用于检测重定义是否无趣（即设置为简单字面量后再次赋值）
predicate uninteresting_definition(AstNode asgn1) {
  exists(AssignStmt a | a.getATarget() = asgn1 | simple_literal(a.getValue())) // 检查是否存在将变量设置为简单字面量的赋值语句
}

// 查询语句，选择所有不必要的赋值操作
from AstNode asgn1, AstNode asgn2, Variable v
where
  multiply_defined(asgn1, asgn2, v) and // 检查变量是否被多次定义
  forall(Name el | el = asgn1.getParentNode().(Tuple).getAnElt() | multiply_defined(el, _, _)) and // 检查所有元组元素是否也被多次定义
  not uninteresting_definition(asgn1) // 排除无趣的重定义情况
select asgn1, // 选择第一个赋值节点
  "This assignment to '" + v.getId() + "' is unnecessary as it is $@ before this value is used.", // 输出警告信息，指出该赋值是不必要的
  asgn2, "redefined" // 选择第二个赋值节点，并标记为“重定义”
