/**
 * @name Statement has no effect
 * @description A statement has no effect
 * @kind problem
 * @tags maintainability
 *       useless-code
 *       external/cwe/cwe-561
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/ineffectual-statement
 */

import python

// 判断属性是否被理解的谓词函数
predicate understood_attribute(Attribute attr, ClassValue cls, ClassValue attr_cls) {
  exists(string name | attr.getName() = name |
    attr.getObject().pointsTo().getClass() = cls and
    cls.attr(name).getClass() = attr_cls
  )
}

/* 保守估计属性查找是否有副作用 */
predicate side_effecting_attribute(Attribute attr) {
  exists(ClassValue attr_cls |
    understood_attribute(attr, _, attr_cls) and
    side_effecting_descriptor_type(attr_cls)
  )
}

// 可能具有副作用的属性谓词函数
predicate maybe_side_effecting_attribute(Attribute attr) {
  not understood_attribute(attr, _, _) and not attr.pointsTo(_)
  or
  side_effecting_attribute(attr)
}

// 判断描述符类型是否有副作用的谓词函数
predicate side_effecting_descriptor_type(ClassValue descriptor) {
  descriptor.isDescriptorType() and
  // 技术上所有描述符获取都有副作用，但有些表示缺少调用，我们希望将它们视为没有效果。
  not descriptor = ClassValue::functionType() and
  not descriptor = ClassValue::staticmethod() and
  not descriptor = ClassValue::classmethod()
}

/**
 * 有副作用的二元运算符很少见，所以我们假设它们没有副作用，除非我们知道它们有。
 */
predicate side_effecting_binary(Expr b) {
  exists(Expr sub, ClassValue cls, string method_name |
    binary_operator_special_method(b, sub, cls, method_name)
    or
    comparison_special_method(b, sub, cls, method_name)
  |
    method_name = special_method() and
    cls.hasAttribute(method_name) and
    not exists(ClassValue declaring |
      declaring.declaresAttribute(method_name) and
      declaring = cls.getASuperType() and
      declaring.isBuiltin() and
      not declaring = ClassValue::object()
    )
  )
}

pragma[nomagic]
private predicate binary_operator_special_method(
  BinaryExpr b, Expr sub, ClassValue cls, string method_name
) {
  method_name = special_method() and
  sub = b.getLeft() and
  method_name = b.getOp().getSpecialMethodName() and
  sub.pointsTo().getClass() = cls
}

pragma[nomagic]
private predicate comparison_special_method(Compare b, Expr sub, ClassValue cls, string method_name) {
  exists(Cmpop op |
    b.compares(sub, op, _) and
    method_name = op.getSpecialMethodName()
  ) and
  sub.pointsTo().getClass() = cls
}

private string special_method() {
  result = any(Cmpop c).getSpecialMethodName()
  or
  result = any(BinaryExpr b).getOp().getSpecialMethodName()
}

// 判断文件是否是Jupyter/IPython笔记本的谓词函数
predicate is_notebook(File f) {
  exists(Comment c | c.getLocation().getFile() = f |
    c.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

/** Jupyter/IPython笔记本中的表达式（语句） */
predicate in_notebook(Expr e) { is_notebook(e.getScope().(Module).getFile()) }

// 获取unittest.TestCase类中的assertRaises方法的FunctionValue对象
FunctionValue assertRaises() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

/** 如果表达式`e`在测试异常引发的`with`块中，则成立。 */
predicate in_raises_test(Expr e) {
  exists(With w |
    w.contains(e) and
    w.getContextExpr() = assertRaises().getACall().getNode()
  )
}

/** 如果表达式具有Python 2 `print >> out, ...`语句的形式，则成立 */
predicate python2_print(Expr e) {
  e.(BinaryExpr).getLeft().(Name).getId() = "print" and
  e.(BinaryExpr).getOp() instanceof RShift
  or
  python2_print(e.(Tuple).getElt(0))
}

// 判断表达式是否没有效果的谓词函数
predicate no_effect(Expr e) {
  // 字符串可以用作注释
  not e instanceof StringLiteral and
  not e.hasSideEffects() and
  forall(Expr sub | sub = e.getASubExpression*() |
    not side_effecting_binary(sub) and
    not maybe_side_effecting_attribute(sub)
  ) and
  not in_notebook(e) and
  not in_raises_test(e) and
  not python2_print(e)
}

// 从表达式语句中选择没有效果的语句并报告问题
from ExprStmt stmt
where no_effect(stmt.getValue())
select stmt, "This statement has no effect."
