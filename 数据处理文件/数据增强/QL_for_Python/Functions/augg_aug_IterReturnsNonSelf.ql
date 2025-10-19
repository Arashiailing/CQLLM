/**
 * @name Iterator does not return self from `__iter__` method
 * @description 迭代器的 `__iter__` 方法未返回自身实例，违反 Python 迭代器协议。
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
 * 获取迭代器类的 `__iter__` 方法作用域
 * @param targetClass - 目标迭代器类
 * @return - `__iter__` 方法的作用域
 */
Function resolveIterMethodScope(ClassValue targetClass) { 
    result = targetClass.lookup("__iter__").(FunctionValue).getScope() 
}

/**
 * 检查返回值是否为函数的首个参数（通常为 `self`）
 * @param retVal - 待检查的返回值
 * @param enclosingFunc - 包含该返回值的函数
 */
predicate returnsSelfInstance(Name retVal, Function enclosingFunc) { 
    retVal.getVariable() = enclosingFunc.getArg(0).(Name).getVariable() 
}

/**
 * 检测函数是否存在隐式返回（无显式 return 语句）
 * @param targetFunc - 待检查的函数
 */
predicate hasImplicitReturn(Function targetFunc) {
    exists(targetFunc.getFallthroughNode())
}

/**
 * 检测函数是否存在无返回值的 return 语句
 * @param targetFunc - 待检查的函数
 */
predicate hasEmptyReturn(Function targetFunc) {
    exists(Return retStmt | 
        retStmt.getScope() = targetFunc and 
        not exists(retStmt.getValue())
    )
}

/**
 * 检测函数是否存在非自身实例的返回值
 * @param targetFunc - 待检查的函数
 */
predicate hasInvalidReturn(Function targetFunc) {
    exists(Return retStmt | 
        retStmt.getScope() = targetFunc and 
        not returnsSelfInstance(retStmt.getValue(), targetFunc)
    )
}

// 主查询：定位违反迭代器协议的类
from ClassValue iteratorCls, Function iterMethod
where 
    // 条件1：验证目标类是迭代器
    iteratorCls.isIterator() and 
    // 条件2：获取目标类的 `__iter__` 方法
    iterMethod = resolveIterMethodScope(iteratorCls) and 
    // 条件3：检查方法返回值违反协议（隐式返回/空返回/非自身返回）
    (hasImplicitReturn(iterMethod) or 
     hasEmptyReturn(iterMethod) or 
     hasInvalidReturn(iterMethod))
// 输出结果：目标类、错误描述、违规方法及其名称
select iteratorCls, 
       "Iterator class " + iteratorCls.getName() + " violates protocol: $@ must return 'self'.",
       iterMethod, iterMethod.getName()