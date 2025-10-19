/**
 * @name Unused global variable
 * @description Global variable is defined but not used
 * @kind problem
 * @tags efficiency
 *       useless-code
 *       external/cwe/cwe-563
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/unused-global-variable
 */

import python
import Definition

/**
 * 判断模块是否包含一个复杂的 __all__ 定义。
 * 复杂定义为：不是简单的字符串列表，或者列表中的元素不全是字符串字面量。
 * @param m 模块
 * @return 如果模块包含复杂的 __all__ 定义，返回 true；否则返回 false。
 */
predicate complex_all(Module m) {
  exists(Assign a, GlobalVariable all |
    a.defines(all) and a.getScope() = m and all.getId() = "__all__"
  |
    not a.getValue() instanceof List // 检查 __all__ 是否为简单列表
    or
    exists(Expr e | e = a.getValue().(List).getAnElt() | not e instanceof StringLiteral) // 检查列表元素是否全为字符串字面量
  )
  or
  exists(Call c, GlobalVariable all |
    c.getFunc().(Attribute).getObject() = all.getALoad() and
    c.getScope() = m and
    all.getId() = "__all__" // 检查是否存在对 __all__ 的调用
  )
}

/**
 * 判断名称是否在 forward declaration 中使用。
 * @param used 使用的名称
 * @param mod 模块
 * @return 如果名称在 forward declaration 中使用，返回 true；否则返回 false。
 */
predicate used_in_forward_declaration(Name used, Module mod) {
  exists(StringLiteral s, Annotation annotation |
    s.getS() = used.getId() and
    s.getEnclosingModule() = mod and
    annotation.getASubExpression*() = s // 检查名称是否在注解中使用
  )
}

/**
 * 判断全局变量是否未使用。
 * @param unused 未使用的名称
 * @param v 全局变量
 * @return 如果全局变量未使用，返回 true；否则返回 false。
 */
predicate unused_global(Name unused, GlobalVariable v) {
  not exists(ImportingStmt is | is.contains(unused)) and // 检查名称是否在导入语句中使用
  forex(DefinitionNode defn | defn.getNode() = unused |
    not defn.getValue().getNode() instanceof FunctionExpr and // 检查定义节点是否为函数表达式
    not defn.getValue().getNode() instanceof ClassExpr and // 检查定义节点是否为类表达式
    not exists(Name u |
      // 变量的使用
      u.uses(v)
    |
      // 直接可达的使用
      defn.strictlyReaches(u.getAFlowNode())
      or
      // 间接可达的使用
      defn.getBasicBlock().reachesExit() and u.getScope() != unused.getScope()
    ) and
    not unused.getEnclosingModule().getAnExport() = v.getId() and // 检查变量是否被导出
    not exists(unused.getParentNode().(ClassDef).getDefinedClass().getADecorator()) and // 检查变量是否在类的装饰器中
    not exists(unused.getParentNode().(FunctionDef).getDefinedFunction().getADecorator()) and // 检查变量是否在函数的装饰器中
    unused.defines(v) and // 检查名称是否定义了全局变量
    not name_acceptable_for_unused_variable(v) and // 检查变量名是否可接受为未使用的变量
    not complex_all(unused.getEnclosingModule()) // 检查模块是否包含复杂的 __all__ 定义
  ) and
  not used_in_forward_declaration(unused, unused.getEnclosingModule()) // 检查名称是否在 forward declaration 中使用
}

from Name unused, GlobalVariable v
where
  unused_global(unused, v) and
  // 如果未使用的名称是元组的一部分，则检查元组的所有元素是否都未使用。
  forall(Name el | el = unused.getParentNode().(Tuple).getAnElt() | unused_global(el, _))
select unused, "The global variable '" + v.getId() + "' is not used." // 选择未使用的全局变量并生成警告信息
