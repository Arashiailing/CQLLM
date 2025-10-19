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
predicate understood_attribute(Attribute attribute, ClassValue sourceClass, ClassValue attributeClass) {
  exists(string attributeName | attribute.getName() = attributeName |
    attribute.getObject().pointsTo().getClass() = sourceClass and
    sourceClass.attr(attributeName).getClass() = attributeClass
  )
}

/* 保守估计属性查找是否有副作用 */
predicate side_effecting_attribute(Attribute attribute) {
  exists(ClassValue attributeClass |
    understood_attribute(attribute, _, attributeClass) and
    side_effecting_descriptor_type(attributeClass)
  )
}

// 可能具有副作用的属性谓词函数
predicate maybe_side_effecting_attribute(Attribute attribute) {
  // 两种情况：属性未被理解或未指向具体值
  (not understood_attribute(attribute, _, _) and not attribute.pointsTo(_))
  or
  // 或者已被识别为具有副作用的属性
  side_effecting_attribute(attribute)
}

// 判断描述符类型是否有副作用的谓词函数
predicate side_effecting_descriptor_type(ClassValue descriptorClass) {
  descriptorClass.isDescriptorType() and
  // 技术上所有描述符获取都有副作用，但有些表示缺少调用，我们希望将它们视为没有效果
  not descriptorClass = ClassValue::functionType() and
  not descriptorClass = ClassValue::staticmethod() and
  not descriptorClass = ClassValue::classmethod()
}

/**
 * 有副作用的二元运算符很少见，所以我们假设它们没有副作用，除非我们知道它们有
 */
predicate side_effecting_binary(Expr binaryExpr) {
  exists(Expr subExpr, ClassValue exprClass, string methodName |
    // 处理二元运算符特殊方法
    binary_operator_special_method(binaryExpr, subExpr, exprClass, methodName)
    or
    // 处理比较运算符特殊方法
    comparison_special_method(binaryExpr, subExpr, exprClass, methodName)
  |
    methodName = special_method() and
    exprClass.hasAttribute(methodName) and
    // 排除内置类型（object除外）的继承方法
    not exists(ClassValue declaring |
      declaring.declaresAttribute(methodName) and
      declaring = exprClass.getASuperType() and
      declaring.isBuiltin() and
      not declaring = ClassValue::object()
    )
  )
}

pragma[nomagic]
private predicate binary_operator_special_method(
  BinaryExpr binaryExpr, Expr subExpr, ClassValue exprClass, string methodName
) {
  methodName = special_method() and
  subExpr = binaryExpr.getLeft() and
  methodName = binaryExpr.getOp().getSpecialMethodName() and
  subExpr.pointsTo().getClass() = exprClass
}

pragma[nomagic]
private predicate comparison_special_method(Compare binaryExpr, Expr subExpr, ClassValue exprClass, string methodName) {
  exists(Cmpop op |
    binaryExpr.compares(subExpr, op, _) and
    methodName = op.getSpecialMethodName()
  ) and
  subExpr.pointsTo().getClass() = exprClass
}

private string special_method() {
  result = any(Cmpop c).getSpecialMethodName()
  or
  result = any(BinaryExpr b).getOp().getSpecialMethodName()
}

// 判断文件是否是Jupyter/IPython笔记本的谓词函数
predicate is_notebook(File file) {
  exists(Comment comment | comment.getLocation().getFile() = file |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

/** Jupyter/IPython笔记本中的表达式（语句） */
predicate in_notebook(Expr expr) { 
  is_notebook(expr.getScope().(Module).getFile()) 
}

// 获取unittest.TestCase类中的assertRaises方法的FunctionValue对象
FunctionValue assertRaises() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

/** 如果表达式`expr`在测试异常引发的`with`块中，则成立 */
predicate in_raises_test(Expr expr) {
  exists(With withStmt |
    withStmt.contains(expr) and
    withStmt.getContextExpr() = assertRaises().getACall().getNode()
  )
}

/** 如果表达式具有Python 2 `print >> out, ...`语句的形式，则成立 */
predicate python2_print(Expr expr) {
  // 处理 print >> 语法
  (expr.(BinaryExpr).getLeft().(Name).getId() = "print" and
   expr.(BinaryExpr).getOp() instanceof RShift)
  or
  // 递归处理元组中的第一个元素
  python2_print(expr.(Tuple).getElt(0))
}

// 判断表达式是否没有效果的谓词函数
predicate no_effect(Expr expr) {
  // 字符串可以用作注释
  not expr instanceof StringLiteral and
  not expr.hasSideEffects() and
  // 检查所有子表达式
  forall(Expr subExpr | subExpr = expr.getASubExpression*() |
    not side_effecting_binary(subExpr) and
    not maybe_side_effecting_attribute(subExpr)
  ) and
  // 排除特殊情况
  not in_notebook(expr) and
  not in_raises_test(expr) and
  not python2_print(expr)
}

// 从表达式语句中选择没有效果的语句并报告问题
from ExprStmt stmt
where no_effect(stmt.getValue())
select stmt, "This statement has no effect."