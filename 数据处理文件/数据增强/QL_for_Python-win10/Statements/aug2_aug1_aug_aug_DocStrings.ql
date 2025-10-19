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

// 判断函数是否需要文档字符串
// 需要满足以下所有条件：
// 1. 不覆盖基类中不需要文档字符串的方法
// 2. 不是lambda函数
// 3. 代码长度（不包括装饰器）超过2行
// 4. 不是属性的getter或setter方法
predicate function_requires_documentation(Function functionToCheck) {
  not exists(FunctionValue overrideFunc, FunctionValue baseFunc | 
    overrideFunc.overrides(baseFunc) and overrideFunc.getScope() = functionToCheck |
    not function_requires_documentation(baseFunc.getScope())
  ) and
  functionToCheck.getName() != "lambda" and
  (functionToCheck.getMetrics().getNumberOfLinesOfCode() - count(functionToCheck.getADecorator())) > 2 and
  not exists(PythonPropertyObject propObj |
    propObj.getGetter().getFunction() = functionToCheck or
    propObj.getSetter().getFunction() = functionToCheck
  )
}

// 获取代码作用域的类型描述
string get_scope_type_description(Scope scopeToDescribe) {
  // 非包模块
  result = "Module" and scopeToDescribe instanceof Module and not scopeToDescribe.(Module).isPackage()
  // 类作用域
  or
  result = "Class" and scopeToDescribe instanceof Class
  // 函数作用域
  or
  result = "Function" and scopeToDescribe instanceof Function
}

// 判断代码作用域是否需要文档字符串
// 作用域必须是公共的，并且满足以下任一条件：
// - 不是函数（例如类或模块）
// - 是函数，但满足文档字符串要求
predicate scope_requires_documentation(Scope scopeToCheck) {
  scopeToCheck.isPublic() and
  (
    not scopeToCheck instanceof Function
    or
    function_requires_documentation(scopeToCheck)
  )
}

// 查找需要文档字符串但缺少文档字符串的公共作用域
from Scope scopeToCheck
where scope_requires_documentation(scopeToCheck) and not exists(scopeToCheck.getDocString())
select scopeToCheck, get_scope_type_description(scopeToCheck) + " " + scopeToCheck.getName() + " does not have a docstring."