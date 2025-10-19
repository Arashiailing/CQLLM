/**
 * @name Unused local variable
 * @description Local variable is defined but not used
 * @kind problem
 * @tags maintainability
 *       useless-code
 *       external/cwe/cwe-563
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/unused-local-variable
 */

import python
import Definition

// 定义一个谓词，用于判断局部变量是否未被使用
predicate unused_local(Name unused, LocalVariable v) {
  // 遍历所有与未使用名称相关的定义
  forex(Definition def | def.getNode() = unused |
    // 检查定义的变量是否为v且未被使用
    def.getVariable() = v and
    def.isUnused() and
    // 确保没有重新定义的情况
    not exists(def.getARedef()) and
    // 确保没有仅包含注释而没有赋值的情况
    not exists(annotation_without_assignment(v)) and
    // 检查定义是否相关
    def.isRelevant() and
    // 确保变量不是nonlocal变量
    not v = any(Nonlocal n).getAVariable() and
    // 确保父节点不是函数装饰器
    not exists(def.getNode().getParentNode().(FunctionDef).getDefinedFunction().getADecorator()) and
    // 确保父节点不是类装饰器
    not exists(def.getNode().getParentNode().(ClassDef).getDefinedClass().getADecorator())
  )
}

/**
 * 获取局部变量`v`的任何注释，这些注释不会重新赋值其值。
 *
 * TODO: 此谓词不应是必需的。相反，不实际赋值的注释不应导致创建未使用的SSA变量。
 */
private AnnAssign annotation_without_assignment(LocalVariable v) {
  // 检查结果的目标是否为变量的存储位置且没有赋值
  result.getTarget() = v.getAStore() and
  not exists(result.getValue())
}

// 从名称和局部变量中选择未使用的变量
from Name unused, LocalVariable v
where
  // 检查变量是否未使用
  unused_local(unused, v) and
  // 如果未使用的是元组的一部分，则当元组的所有元素都未使用时才计数为未使用
  forall(Name el | el = unused.getParentNode().(Tuple).getAnElt() | unused_local(el, _))
select unused, "Variable " + v.getId() + " is not used."
