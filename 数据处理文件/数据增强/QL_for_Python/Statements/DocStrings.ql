/**
 * @name Missing docstring
 * @description Omitting documentation strings from public classes, functions or methods
 *              makes it more difficult for other developers to maintain the code.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * NOTE: precision of 'medium' reflects the lack of precision in the underlying rule.
 * Do we care whether a function has a docstring? That often depends on the reader of that docstring.
 */

import python

// 定义一个谓词函数，用于判断某个作用域是否需要文档字符串
predicate needs_docstring(Scope s) {
  // 检查作用域是否为公共的，并且满足以下条件之一：
  // 1. 不是函数类型的作用域
  // 2. 是函数类型且需要文档字符串
  s.isPublic() and
  (
    not s instanceof Function
    or
    function_needs_docstring(s)
  )
}

// 定义一个谓词函数，用于判断某个函数是否需要文档字符串
predicate function_needs_docstring(Function f) {
  // 检查函数是否没有被重写，并且函数名不是"lambda"，且代码行数大于2，且不是属性的getter或setter方法
  not exists(FunctionValue fo, FunctionValue base | fo.overrides(base) and fo.getScope() = f |
    not function_needs_docstring(base.getScope())
  ) and
  f.getName() != "lambda" and
  (f.getMetrics().getNumberOfLinesOfCode() - count(f.getADecorator())) > 2 and
  not exists(PythonPropertyObject p |
    p.getGetter().getFunction() = f or
    p.getSetter().getFunction() = f
  )
}

// 定义一个函数，用于返回作用域的类型（模块、类或函数）
string scope_type(Scope s) {
  // 如果作用域是模块且不是包，则返回"Module"
  result = "Module" and s instanceof Module and not s.(Module).isPackage()
  // 如果作用域是类，则返回"Class"
  or
  result = "Class" and s instanceof Class
  // 如果作用域是函数，则返回"Function"
  or
  result = "Function" and s instanceof Function
}

// 查询语句，选择所有需要文档字符串但没有文档字符串的作用域，并输出其类型和名称
from Scope s
where needs_docstring(s) and not exists(s.getDocString())
select s, scope_type(s) + " " + s.getName() + " does not have a docstring."
