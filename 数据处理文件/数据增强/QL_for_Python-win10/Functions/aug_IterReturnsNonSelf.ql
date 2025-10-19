/**
 * @name Iterator does not return self from `__iter__` method
 * @description 迭代器的 `__iter__` 方法没有返回自身，违反了 Python 迭代器协议。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-self
 */

import python

/**
 * 获取指定类的 `__iter__` 方法的作用域。
 * @param iteratorClass - 要检查的类
 * @return - `__iter__` 方法的作用域
 */
Function getIterMethodScope(ClassValue iteratorClass) { 
    result = iteratorClass.lookup("__iter__").(FunctionValue).getScope() 
}

/**
 * 检查给定的返回值是否与函数的第一个参数（通常是 `self`）相同。
 * @param returnedValue - 要检查的返回值
 * @param func - 包含该返回值的函数
 */
predicate isSelfReturn(Name returnedValue, Function func) { 
    returnedValue.getVariable() = func.getArg(0).(Name).getVariable() 
}

/**
 * 检查函数是否有 fallthrough 节点（即没有显式返回）。
 * @param func - 要检查的函数
 */
predicate hasFallthroughNode(Function func) {
    exists(func.getFallthroughNode())
}

/**
 * 检查函数是否有返回语句但没有返回值。
 * @param func - 要检查的函数
 */
predicate hasReturnWithoutValue(Function func) {
    exists(Return retStmt | 
        retStmt.getScope() = func and 
        not exists(retStmt.getValue())
    )
}

/**
 * 检查函数是否有返回语句但返回的值不是自身。
 * @param func - 要检查的函数
 */
predicate hasNonSelfReturn(Function func) {
    exists(Return retStmt | 
        retStmt.getScope() = func and 
        not isSelfReturn(retStmt.getValue(), func)
    )
}

/**
 * 检查函数是否返回非自身或没有返回值。
 * @param func - 要检查的函数
 */
predicate returnsNonSelf(Function func) {
    hasFallthroughNode(func) or
    hasNonSelfReturn(func) or
    hasReturnWithoutValue(func)
}

// 主查询：查找所有违反迭代器协议的迭代器类
from ClassValue iteratorClass, Function iterMethod
// 条件1：iteratorClass 是一个迭代器
where iteratorClass.isIterator() and 
      // 条件2：iterMethod 是 iteratorClass 的 `__iter__` 方法
      iterMethod = getIterMethodScope(iteratorClass) and 
      // 条件3：iterMethod 方法返回非自身或没有返回值
      returnsNonSelf(iterMethod)
// 选择结果包括类 iteratorClass、错误信息、函数 iterMethod 以及其名称
select iteratorClass, 
       "Class " + iteratorClass.getName() + " is an iterator but its $@ method does not return 'self'.",
       iterMethod, iterMethod.getName()