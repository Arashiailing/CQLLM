/**
 * @name Missing docstring
 * @description Public classes, functions, or methods without documentation strings
 *              hinder code maintainability and understanding for other developers.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * NOTE: The 'medium' precision reflects the subjective nature of docstring requirements.
 * The necessity of a docstring often depends on the context and intended audience.
 */

import python

// 判断代码作用域是否需要文档字符串
// 作用域必须是公共的，并且满足以下任一条件：
// - 不是函数（例如类或模块）
// - 是函数，但满足文档字符串要求
predicate should_have_documentation(Scope targetScope) {
  targetScope.isPublic() and
  (
    not targetScope instanceof Function
    or
    function_needs_documentation(targetScope)
  )
}

// 判断函数是否需要文档字符串
// 需要满足以下所有条件：
// 1. 不覆盖基类中不需要文档字符串的方法
// 2. 不是lambda函数
// 3. 代码长度（不包括装饰器）超过2行
// 4. 不是属性的getter或setter方法
predicate function_needs_documentation(Function func) {
  not exists(FunctionValue overrideFunc, FunctionValue baseFunc | 
    overrideFunc.overrides(baseFunc) and overrideFunc.getScope() = func |
    not function_needs_documentation(baseFunc.getScope())
  ) and
  func.getName() != "lambda" and
  (func.getMetrics().getNumberOfLinesOfCode() - count(func.getADecorator())) > 2 and
  not exists(PythonPropertyObject propObj |
    propObj.getGetter().getFunction() = func or
    propObj.getSetter().getFunction() = func
  )
}

// 获取代码作用域的类型描述
string get_scope_description(Scope targetScope) {
  // 非包模块
  result = "Module" and targetScope instanceof Module and not targetScope.(Module).isPackage()
  // 类作用域
  or
  result = "Class" and targetScope instanceof Class
  // 函数作用域
  or
  result = "Function" and targetScope instanceof Function
}

// 查找需要文档字符串但缺少文档字符串的公共作用域
from Scope targetScope
where should_have_documentation(targetScope) and not exists(targetScope.getDocString())
select targetScope, get_scope_description(targetScope) + " " + targetScope.getName() + " does not have a docstring."