/**
 * @name Modification of dictionary returned by locals()
 * @description Modifications of the dictionary returned by locals() are not propagated to the local variables of a function.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/modification-of-locals
 */

import python

// 定义一个谓词，用于判断控制流节点是否指向名为 "locals" 的调用
predicate originIsLocals(ControlFlowNode n) { 
    n.pointsTo(_, _, Value::named("locals").getACall()) 
}

// 定义一个谓词，用于判断是否存在对 locals() 返回字典的修改操作
predicate modification_of_locals(ControlFlowNode f) {
    // 如果当前节点是下标节点，并且其对象是由 locals() 返回的字典，同时该节点是存储或删除操作
    originIsLocals(f.(SubscriptNode).getObject()) and
    (f.isStore() or f.isDelete())
    // 或者存在一个方法调用节点，该方法名在 ["pop", "popitem", "update", "clear"] 中，并且该方法的对象是由 locals() 返回的字典
    or
    exists(string mname, AttrNode attr |
        attr = f.(CallNode).getFunction() and
        originIsLocals(attr.getObject(mname))
    |
        mname in ["pop", "popitem", "update", "clear"]
    )
}

// 从 AstNode 和 ControlFlowNode 中选择满足条件的节点
from AstNode a, ControlFlowNode f
where
    // 条件1：存在对 locals() 返回字典的修改操作
    modification_of_locals(f) and
    // 条件2：获取与控制流节点对应的 AST 节点
    a = f.getNode() and
    // 条件3：排除模块级别作用域，因为在模块级别作用域中 `locals() == globals()`
    not a.getScope() instanceof ModuleScope
// 选择结果并附加警告信息
select a, "Modification of the locals() dictionary will have no effect on the local variables."
