/**
 * @name Missing docstring
 * @description Public classes, functions or methods without documentation strings 
 *              reduce code maintainability by making it harder for other developers 
 *              to understand the code's purpose and usage.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * Note: Medium precision due to the inherent subjectivity in determining when a 
 * docstring is required. The necessity often depends on the code's context and 
 * intended audience.
 */

import python

// 判断作用域是否需要文档字符串
predicate requires_documentation(Scope scope) {
  scope.isPublic() and
  (
    not scope instanceof Function
    or
    function_needs_documentation(scope)
  )
}

// 判断函数是否需要文档字符串
predicate function_needs_documentation(Function func) {
  func.getName() != "lambda" and
  // 计算实际代码行数（排除装饰器）
  (func.getMetrics().getNumberOfLinesOfCode() - count(func.getADecorator())) > 2 and
  // 排除属性访问器方法
  not exists(PythonPropertyObject propObj |
    propObj.getGetter().getFunction() = func or
    propObj.getSetter().getFunction() = func
  ) and
  // 检查重写方法：如果被重写的方法不需要文档，则当前方法也不需要
  not exists(FunctionValue overrideFunc, FunctionValue baseFunc | 
    overrideFunc.overrides(baseFunc) and overrideFunc.getScope() = func |
    not function_needs_documentation(baseFunc.getScope())
  )
}

// 获取作用域的类型名称（模块、类或函数）
string get_scope_type_name(Scope scope) {
  result = "Module" and scope instanceof Module and not scope.(Module).isPackage()
  or
  result = "Class" and scope instanceof Class
  or
  result = "Function" and scope instanceof Function
}

// 查找需要文档但缺少文档的作用域
from Scope scope
where requires_documentation(scope) and not exists(scope.getDocString())
select scope, get_scope_type_name(scope) + " " + scope.getName() + " does not have a docstring."