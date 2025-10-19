/**
 * @name Deprecated slice method
 * @description Identifies usage of deprecated slicing special methods which have been obsolete since Python 2.0.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

// 谓词函数：验证输入的方法名是否属于已弃用的切片方法集合
predicate is_deprecated_slice_method(string methodName) {
  // 方法名必须是以下三种已弃用的切片方法之一
  methodName = "__getslice__" or methodName = "__setslice__" or methodName = "__delslice__"
}

// 查询源：从Python函数值中筛选目标
from PythonFunctionValue funcObj, string methodName
where
  // 条件1：函数名与方法名匹配，且该方法名是已弃用的切片方法
  funcObj.getName() = methodName and
  is_deprecated_slice_method(methodName) and
  // 条件2：函数必须是一个类方法
  funcObj.getScope().isMethod() and
  // 条件3：函数不能是重写父类的方法
  not funcObj.isOverridingMethod()
// 输出结果：显示函数对象和相应的弃用警告信息
select funcObj, methodName + " method has been deprecated since Python 2.0."