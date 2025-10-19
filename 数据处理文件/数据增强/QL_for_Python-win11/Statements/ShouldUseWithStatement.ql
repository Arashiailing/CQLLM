/**
 * @name Should use a 'with' statement
 * @description Using a 'try-finally' block to ensure only that a resource is closed makes code more
 *              difficult to read.
 * @kind problem
 * @tags maintainability
 *       readability
 *       convention
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/should-use-with
 */

import python

// 定义一个谓词函数，用于判断调用是否为close方法
predicate calls_close(Call c) { 
    exists(Attribute a | c.getFunc() = a and a.getName() = "close") 
}

// 定义一个谓词函数，用于判断在finally块中是否只有一条语句且该语句是close方法的调用
predicate only_stmt_in_finally(Try t, Call c) {
    exists(ExprStmt s |
        t.getAFinalstmt() = s and s.getValue() = c and strictcount(t.getAFinalstmt()) = 1
    )
}

// 定义一个谓词函数，用于判断控制流节点是否指向上下文管理器类的实例
predicate points_to_context_manager(ControlFlowNode f, ClassValue cls) {
    forex(Value v | f.pointsTo(v) | v.getClass() = cls) and
    cls.isContextManager()
}

// 查询语句：查找所有在finally块中仅包含close方法调用的代码，并建议使用'with'语句
from Call close, Try t, ClassValue cls
where
    only_stmt_in_finally(t, close) and // 检查finally块中是否只有一条语句且该语句是close方法的调用
    calls_close(close) and // 检查调用是否为close方法
    exists(ControlFlowNode f | f = close.getFunc().getAFlowNode().(AttrNode).getObject() |
        points_to_context_manager(f, cls) // 检查控制流节点是否指向上下文管理器类的实例
    )
select close,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.", // 提示信息
    cls, cls.getName() // 选择上下文管理器类及其名称
