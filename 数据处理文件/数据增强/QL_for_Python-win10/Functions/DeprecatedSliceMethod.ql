/**
 * @name Deprecated slice method
 * @description Defining special methods for slicing has been deprecated since Python 2.0.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

// 定义一个谓词函数，用于判断给定的方法名是否是已弃用的切片方法名
predicate slice_method_name(string name) {
  // 检查方法名是否为 "__getslice__", "__setslice__" 或 "__delslice__"
  name = "__getslice__" or name = "__setslice__" or name = "__delslice__"
}

// 从PythonFunctionValue类中选择函数f和字符串meth
from PythonFunctionValue f, string meth
where
  // 确保f是一个方法
  f.getScope().isMethod() and
  // 确保f不是重写的方法
  not f.isOverridingMethod() and
  // 确保meth是已弃用的切片方法名
  slice_method_name(meth) and
  // 确保f的名称与meth相同
  f.getName() = meth
// 选择满足条件的函数f和方法名meth，并返回警告信息
select f, meth + " method has been deprecated since Python 2.0."
