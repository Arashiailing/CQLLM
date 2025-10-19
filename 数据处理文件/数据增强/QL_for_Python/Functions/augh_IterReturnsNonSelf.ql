/**
 * @name Iterator does not return self from `__iter__` method
 * @description 迭代器的 `__iter__` 方法未返回自身实例，违反了迭代器协议要求
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-self
 */

import python

// 获取指定迭代器类的 __iter__ 方法实现
Function getIterMethod(ClassValue iteratorClass) { 
  result = iteratorClass.lookup("__iter__").(FunctionValue).getScope() 
}

// 检查返回值是否为当前方法的第一个参数（即 self）
predicate isSelfReference(Name returnedValue, Function method) { 
  returnedValue.getVariable() = method.getArg(0).(Name).getVariable() 
}

// 检查方法是否存在无效返回情况（无返回值/返回非自身/隐式返回）
predicate hasInvalidReturn(Function method) {
  // 情况1：方法存在隐式返回（无显式return语句）
  exists(method.getFallthroughNode())
  or
  // 情况2：存在返回非自身值的return语句
  exists(Return returnStmt | 
    returnStmt.getScope() = method and 
    not isSelfReference(returnStmt.getValue(), method)
  )
  or
  // 情况3：存在无返回值的return语句
  exists(Return returnStmt | 
    returnStmt.getScope() = method and 
    not exists(returnStmt.getValue())
  )
}

// 查询所有违反迭代器协议的类及其 __iter__ 方法
from ClassValue iteratorClass, Function iterMethod
where 
  // 确保目标类是迭代器
  iteratorClass.isIterator() and 
  // 获取类的 __iter__ 方法实现
  iterMethod = getIterMethod(iteratorClass) and 
  // 验证方法存在无效返回行为
  hasInvalidReturn(iterMethod)
// 输出结果：问题类、错误描述、问题方法及方法名
select iteratorClass, 
  "Iterator class " + iteratorClass.getName() + " violates protocol: $@ should return 'self'.",
  iterMethod, iterMethod.getName()