/**
 * @name Use of a print statement at module level
 * @description Using a print statement at module scope (except when guarded by `if __name__ == '__main__'`) will cause surprising output when the module is imported.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       convention
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/print-during-import
 */

import python

// 定义一个谓词函数，用于判断是否在主程序中（即 if __name__ == '__main__'）
predicate main_eq_name(If i) {
  exists(Name n, StringLiteral m, Compare c |
    i.getTest() = c and // 获取 if 语句的条件部分
    c.getLeft() = n and // 比较的左操作数是 __name__
    c.getAComparator() = m and // 比较的右操作数是字符串 "__main__"
    n.getId() = "__name__" and // 确认左操作数是 __name__
    m.getText() = "__main__" // 确认右操作数是 "__main__"
  )
}

// 定义一个谓词函数，用于判断是否是 print 语句
predicate is_print_stmt(Stmt s) {
  s instanceof Print // 如果语句是 Print 类型
  or
  exists(ExprStmt e, Call c, Name n |
    e = s and // 确认语句是表达式语句
    c = e.getValue() and // 获取表达式中的调用部分
    n = c.getFunc() and // 获取调用的函数名
    n.getId() = "print" // 确认函数名是 print
  )
}

// 从所有语句中查找符合条件的 print 语句
from Stmt p
where
  is_print_stmt(p) and // 确认语句是 print 语句
  // TODO: Need to discuss how we would like to handle ModuleObject.getKind in the glorious future
  exists(ModuleValue m | m.getScope() = p.getScope() and m.isUsedAsModule()) and // 确认语句所在的模块被用作模块导入
  not exists(If i | main_eq_name(i) and i.getASubStatement().getASubStatement*() = p) // 确认 print 语句不在 if __name__ == '__main__' 块内
select p, "Print statement may execute during import." // 选择并报告可能的 print 语句问题
