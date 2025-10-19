/**
 * @name Unused parameter
 * @description 参数已定义但未使用
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision medium
 * @id py/unused-parameter
 */

import python
import Definition

// 谓词：检查参数是否未被使用
predicate unused_parameter(FunctionValue f, LocalVariable v) {
  // 检查变量是否是参数
  v.isParameter() and
  // 检查变量的作用域是否与函数的作用域相同
  v.getScope() = f.getScope() and
  // 检查变量名是否符合未使用变量的命名规范
  not name_acceptable_for_unused_variable(v) and
  // 检查变量是否没有被任何名称节点使用
  not exists(NameNode u | u.uses(v)) and
  // 检查变量是否没有在内部作用域中被使用
  not exists(Name inner, LocalVariable iv |
    inner.uses(iv) and iv.getId() = v.getId() and inner.getScope().getScope() = v.getScope()
  )
}

// 谓词：检查函数是否是抽象函数
predicate is_abstract(FunctionValue func) {
  // 检查函数是否有装饰器，并且装饰器的名称匹配"abstract"
  func.getScope().getADecorator().(Name).getId().matches("%abstract%")
}

// 从Python函数和值中选择未使用的参数
from PythonFunctionValue f, LocalVariable v
where
  // 排除self参数
  v.getId() != "self" and
  // 检查参数是否未被使用
  unused_parameter(f, v) and
  // 排除重写方法的情况
  not f.isOverridingMethod() and
  // 排除被重写的方法的情况
  not f.isOverriddenMethod() and
  // 排除抽象函数的情况
  not is_abstract(f)
select f, "The parameter '" + v.getId() + "' is never used."
