/**
 * @name Potentially uninitialized local variable
 * @description Using a local variable before it is initialized causes an UnboundLocalError.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/uninitialized-local-variable
 */

import python  // 导入python库，用于处理Python代码的解析和分析
import Undefined  // 导入Undefined库，用于处理未定义变量的情况
import semmle.python.pointsto.PointsTo  // 导入PointsTo库，用于处理变量指向分析

// 定义一个谓词函数，用于判断局部变量是否未初始化
predicate uninitialized_local(NameNode use) {
  exists(FastLocalVariable local | use.uses(local) or use.deletes(local) |
    not local.escapes() and not local = any(Nonlocal nl).getAVariable()
  ) and
  (
    any(Uninitialized uninit).taints(use) and
    PointsToInternal::reachableBlock(use.getBasicBlock(), _)
    or
    not exists(EssaVariable var | var.getASourceUse() = use)
  )
}

// 定义一个谓词函数，用于判断变量使用是否被显式保护（如在try块中）
predicate explicitly_guarded(NameNode u) {
  exists(Try t |
    t.getBody().contains(u.getNode()) and
    t.getAHandler().getType().pointsTo(ClassValue::nameError())
  )
}

// 从NameNode节点开始查询
from NameNode u
// 条件：局部变量未初始化且没有被显式保护
where uninitialized_local(u) and not explicitly_guarded(u)
// 选择结果并输出警告信息
select u.getNode(), "Local variable '" + u.getId() + "' may be used before it is initialized."
