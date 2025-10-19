/**
 * @name Iterator does not return self from `__iter__` method
 * @description 迭代器的 `__iter__` 方法没有返回自身，违反了迭代器协议。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-self
 */

import python

// 定义一个函数 iter_method，它接受一个类值 t 并返回该类的 `__iter__` 方法的作用域
Function iter_method(ClassValue t) { result = t.lookup("__iter__").(FunctionValue).getScope() }

// 定义一个谓词 is_self，用于检查给定的值是否与函数的第一个参数相同
predicate is_self(Name value, Function f) { value.getVariable() = f.getArg(0).(Name).getVariable() }

// 定义一个谓词 returns_non_self，用于检查函数是否返回非自身或没有返回值
predicate returns_non_self(Function f) {
  // 检查函数是否有 fallthrough 节点（即没有显式返回）
  exists(f.getFallthroughNode())
  // 或者函数有返回语句，但返回的值不是自身
  or
  exists(Return r | r.getScope() = f and not is_self(r.getValue(), f))
  // 或者函数有返回语句，但没有返回值
  or
  exists(Return r | r.getScope() = f and not exists(r.getValue()))
}

// 从所有类值 t 和函数 iter 中选择满足以下条件的结果：
from ClassValue t, Function iter
// 条件1：t 是一个迭代器
where t.isIterator() and 
      // 条件2：iter 是 t 的 `__iter__` 方法
      iter = iter_method(t) and 
      // 条件3：iter 方法返回非自身或没有返回值
      returns_non_self(iter)
// 选择结果包括类 t、错误信息、函数 iter 以及其名称
select t, "Class " + t.getName() + " is an iterator but its $@ method does not return 'self'.",
  iter, iter.getName()
