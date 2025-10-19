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

/**
 * 判断给定的方法名是否为已弃用的切片方法。
 * 这些方法包括 "__getslice__", "__setslice__" 和 "__delslice__"。
 */
predicate is_deprecated_slice_method(string methodName) {
  methodName = "__getslice__" or 
  methodName = "__setslice__" or 
  methodName = "__delslice__"
}

/**
 * 查找所有已弃用的切片方法定义。
 * 此查询识别自Python 2.0以来已弃用的切片方法实现。
 */
from PythonFunctionValue method, string deprecatedMethodName
where
  // 确保是方法而非普通函数
  method.getScope().isMethod() and
  // 排除重写方法以减少误报
  not method.isOverridingMethod() and
  // 验证方法名属于已弃用的切片方法
  is_deprecated_slice_method(deprecatedMethodName) and
  // 确保方法名与已弃用名称一致
  method.getName() = deprecatedMethodName
// 输出结果并显示警告信息
select method, deprecatedMethodName + " method has been deprecated since Python 2.0."