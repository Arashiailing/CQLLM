/**
 * @name Unreachable code
 * @description Code is unreachable
 * @kind problem
 * @tags maintainability
 *       useless-code
 *       external/cwe/cwe-561
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/unreachable-statement
 */

import python

// 判断是否为类型提示的导入语句
predicate typing_import(ImportingStmt is) {
  exists(Module m |
    is.getScope() = m and // 检查导入语句的作用域是否为模块m
    exists(TypeHintComment tc | tc.getLocation().getFile() = m.getFile()) // 检查模块中是否存在类型提示注释
  )
}

// 判断`s`是否包含作用域内唯一的`yield`语句
predicate unique_yield(Stmt s) {
  exists(Yield y | s.contains(y)) and // 检查`s`中是否存在`yield`语句
  exists(Function f |
    f = s.getScope() and // 获取`s`的作用域函数
    strictcount(Yield y | f.containsInScope(y)) = 1 // 检查函数作用域内是否只有一个`yield`语句
  )
}

// 判断`contextlib.suppress`是否可能与`s`在同一作用域中使用
predicate suppression_in_scope(Stmt s) {
  exists(With w |
    w.getContextExpr().(Call).getFunc().pointsTo(Value::named("contextlib.suppress")) and // 检查with语句的上下文管理器是否指向`contextlib.suppress`
    w.getScope() = s.getScope() // 检查with语句的作用域是否与`s`相同
  )
}

// 判断`s`是否为在if-elif-else链末尾引发异常的语句
predicate marks_an_impossible_else_branch(Stmt s) {
  exists(If i | i.getOrelse().getItem(0) = s |
    s.(Assert).getTest() instanceof False // 检查`s`是否为断言False的语句
    or
    s instanceof Raise // 检查`s`是否为引发异常的语句
  )
}

// 判断`s`是否为可报告的不可达代码
predicate reportable_unreachable(Stmt s) {
  s.isUnreachable() and // 检查`s`是否为不可达代码
  not typing_import(s) and // 排除类型提示的导入语句
  not suppression_in_scope(s) and // 排除在`contextlib.suppress`作用域内的语句
  not exists(Stmt other | other.isUnreachable() |
    other.contains(s) // 排除被其他不可达语句包含的语句
    or
    exists(StmtList l, int i, int j | l.getItem(i) = other and l.getItem(j) = s and i < j) // 排除在其他不可达语句之后的语句
  ) and
  not unique_yield(s) and // 排除包含唯一`yield`语句的代码块
  not marks_an_impossible_else_branch(s) // 排除在if-elif-else链末尾引发异常的语句
}

// 查询不可达代码并选择相应的语句和描述信息
from Stmt s
where reportable_unreachable(s)
select s, "This statement is unreachable."
