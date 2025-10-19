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
predicate is_understood_attribute(Attribute attributeNode, ClassValue sourceClass, ClassValue attributeClass) {
  exists(string attributeName | attributeNode.getName() = attributeName |
    attributeNode.getObject().pointsTo().getClass() = sourceClass and
    sourceClass.attr(attributeName).getClass() = attributeClass
  )
}

/* 保守估计属性查找是否有副作用 */
predicate is_side_effecting_attribute(Attribute attributeNode) {
  exists(ClassValue attributeClass |
    is_understood_attribute(attributeNode, _, attributeClass) and
    is_side_effecting_descriptor_type(attributeClass)
  )
}

// 可能具有副作用的属性谓词函数
predicate is_maybe_side_effecting_attribute(Attribute attributeNode) {
  not is_understood_attribute(attributeNode, _, _) and not attributeNode.pointsTo(_)
  or
  is_side_effecting_attribute(attributeNode)
}

// 判断描述符类型是否有副作用的谓词函数
predicate is_side_effecting_descriptor_type(ClassValue descriptorClass) {
  descriptorClass.isDescriptorType() and
  // 技术上所有描述符获取都有副作用，但有些表示缺少调用，我们希望将它们视为没有效果。
  not descriptorClass = ClassValue::functionType() and
  not descriptorClass = ClassValue::staticmethod() and
  not descriptorClass = ClassValue::classmethod()
}

// 获取特殊方法名的辅助谓词
private string get_special_method_name() {
  result = any(Cmpop c).getSpecialMethodName()
  or
  result = any(BinaryExpr b).getOp().getSpecialMethodName()
}

pragma[nomagic]
private predicate is_binary_operator_special_method(
  BinaryExpr binaryExpr, Expr subExpr, ClassValue sourceClass, string methodName
) {
  methodName = get_special_method_name() and
  subExpr = binaryExpr.getLeft() and
  methodName = binaryExpr.getOp().getSpecialMethodName() and
  subExpr.pointsTo().getClass() = sourceClass
}

pragma[nomagic]
private predicate is_comparison_special_method(Compare comparisonExpr, Expr subExpr, ClassValue sourceClass, string methodName) {
  exists(Cmpop op |
    comparisonExpr.compares(subExpr, op, _) and
    methodName = op.getSpecialMethodName()
  ) and
  subExpr.pointsTo().getClass() = sourceClass
}

/**
 * 有副作用的二元运算符很少见，所以我们假设它们没有副作用，除非我们知道它们有。
 */
predicate is_side_effecting_binary(Expr binaryExpr) {
  exists(Expr subExpr, ClassValue sourceClass, string methodName |
    is_binary_operator_special_method(binaryExpr, subExpr, sourceClass, methodName)
    or
    is_comparison_special_method(binaryExpr, subExpr, sourceClass, methodName)
  |
    methodName = get_special_method_name() and
    sourceClass.hasAttribute(methodName) and
    not exists(ClassValue declaring |
      declaring.declaresAttribute(methodName) and
      declaring = sourceClass.getASuperType() and
      declaring.isBuiltin() and
      not declaring = ClassValue::object()
    )
  )
}

// 判断文件是否是Jupyter/IPython笔记本的谓词函数
predicate is_notebook_file(File file) {
  exists(Comment comment | comment.getLocation().getFile() = file |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

/** Jupyter/IPython笔记本中的表达式（语句） */
predicate is_in_notebook(Expr expression) { 
  is_notebook_file(expression.getScope().(Module).getFile()) 
}

// 获取unittest.TestCase类中的assertRaises方法的FunctionValue对象
FunctionValue get_unittest_assert_raises() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

/** 如果表达式`expression`在测试异常引发的`with`块中，则成立。 */
predicate is_in_raises_test(Expr expression) {
  exists(With withStmt |
    withStmt.contains(expression) and
    withStmt.getContextExpr() = get_unittest_assert_raises().getACall().getNode()
  )
}

/** 如果表达式具有Python 2 `print >> out, ...`语句的形式，则成立 */
predicate is_python2_print(Expr expression) {
  expression.(BinaryExpr).getLeft().(Name).getId() = "print" and
  expression.(BinaryExpr).getOp() instanceof RShift
  or
  is_python2_print(expression.(Tuple).getElt(0))
}

// 判断表达式是否没有效果的谓词函数
predicate is_no_effect_expression(Expr expression) {
  // 字符串可以用作注释
  (not expression instanceof StringLiteral and not expression.hasSideEffects()) and
  // 检查所有子表达式是否没有副作用
  forall(Expr subExpr | subExpr = expression.getASubExpression*() |
    (not is_side_effecting_binary(subExpr) and not is_maybe_side_effecting_attribute(subExpr))
  ) and
  // 排除特殊上下文
  (not is_in_notebook(expression) and not is_in_raises_test(expression) and not is_python2_print(expression))
}

// 从表达式语句中选择没有效果的语句并报告问题
from ExprStmt statement
where is_no_effect_expression(statement.getValue())
select statement, "This statement has no effect."