/**
 * @name Use of an undefined placeholder variable
 * @description Using a variable before it is initialized causes an exception.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/undefined-placeholder-variable
 */

import python
import Variables.MonkeyPatched

// 本地变量部分
predicate initialized_as_local(PlaceHolder use) {
  // 检查是否存在一个局部变量在作用域内被初始化
  exists(SsaVariable l, Function f | f = use.getScope() and l.getAUse() = use.getAFlowNode() |
    l.getVariable() instanceof LocalVariable and
    not l.maybeUndefined()
  )
}

// 不是模板成员的类
Class enclosing_class(PlaceHolder use) { result.getAMethod() = use.getScope() }

// 检查是否为模板属性
predicate template_attribute(PlaceHolder use) {
  // 检查封闭类中是否定义了该名称
  exists(ImportTimeScope cls | cls = enclosing_class(use) | cls.definesName(use.getId()))
}

// 全局变量部分
predicate not_a_global(PlaceHolder use) {
  // 检查变量是否不是全局变量，也不是猴子补丁的内置变量
  not exists(PythonModuleObject mo |
    mo.hasAttribute(use.getId()) and mo.getModule() = use.getEnclosingModule()
  ) and
  not globallyDefinedName(use.getId()) and
  not monkey_patched_builtin(use.getId()) and
  not globallyDefinedName(use.getId())
}

// 查询语句：选择未初始化的占位符变量并报告可能未定义的使用情况
from PlaceHolder p
where
  not initialized_as_local(p) and // 排除已作为局部变量初始化的情况
  not template_attribute(p) and // 排除模板属性的情况
  not_a_global(p) // 排除全局变量的情况
select p, "This use of place-holder variable '" + p.getId() + "' may be undefined." // 选择并报告未定义的占位符变量使用情况
