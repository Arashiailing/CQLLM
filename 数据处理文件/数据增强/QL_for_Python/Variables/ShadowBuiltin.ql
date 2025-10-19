/**
 * @name Builtin shadowed by local variable
 * @description Defining a local variable with the same name as a built-in object
 *              makes the built-in object unusable within the current scope and makes the code
 *              more difficult to read.
 * @kind problem
 * @tags maintainability
 *       readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/local-shadows-builtin
 */

import python
import Shadowing
import semmle.python.types.Builtins

// 定义一个谓词函数，用于判断给定的名称是否在允许列表中。
predicate allow_list(string name) {
  name in [
      /* 这些很少使用，因此不太可能引起混淆 */
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      /* 这些名称较短且/或难以避免 */
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// 定义一个谓词函数，用于判断某个名称是否在当前作用域内被局部变量遮蔽。
predicate shadows(Name d, string name, Function scope, int line) {
  exists(LocalVariable l |
    d.defines(l) and // 检查名称定义了一个局部变量
    l.getId() = name and // 检查局部变量的名称与给定名称相同
    exists(Builtin::builtin(l.getId())) // 检查该名称是一个内置对象
  ) and
  d.getScope() = scope and // 检查名称的作用域
  d.getLocation().getStartLine() = line and // 检查名称的定义行号
  not allow_list(name) and // 检查名称不在允许列表中
  not optimizing_parameter(d) // 检查名称不是优化参数
}

// 定义一个谓词函数，用于判断某个名称是否是第一次在当前作用域内被局部变量遮蔽。
predicate first_shadowing_definition(Name d, string name) {
  exists(int first, Scope scope |
    shadows(d, name, scope, first) and // 检查名称在当前作用域内被局部变量遮蔽
    first = min(int line | shadows(_, name, scope, line)) // 获取第一次遮蔽的行号
  )
}

// 查询语句：查找所有在当前作用域内被局部变量遮蔽的内置对象。
from Name d, string name
where first_shadowing_definition(d, name) // 条件：名称是第一次在当前作用域内被局部变量遮蔽
select d, "Local variable " + name + " shadows a builtin variable." // 选择结果：返回遮蔽的局部变量及其信息
