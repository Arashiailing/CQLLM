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

// ===== 属性理解相关谓词 =====

/**
 * 判断属性是否被理解的谓词函数
 * 检查属性是否属于某个类，并且该属性的类是否已知
 */
predicate understood_attribute(Attribute attribute, ClassValue classValue, ClassValue attributeClass) {
  exists(string attributeName | attribute.getName() = attributeName |
    attribute.getObject().pointsTo().getClass() = classValue and
    classValue.attr(attributeName).getClass() = attributeClass
  )
}

/**
 * 保守估计属性查找是否有副作用
 * 如果属性被理解且其描述符类型有副作用，则认为属性有副作用
 */
predicate side_effecting_attribute(Attribute attribute) {
  exists(ClassValue attributeClass |
    understood_attribute(attribute, _, attributeClass) and
    side_effecting_descriptor_type(attributeClass)
  )
}

/**
 * 判断属性是否可能有副作用
 * 如果属性不被理解或不指向任何值，或者已知有副作用，则认为可能有副作用
 */
predicate maybe_side_effecting_attribute(Attribute attribute) {
  not understood_attribute(attribute, _, _) and not attribute.pointsTo(_)
  or
  side_effecting_attribute(attribute)
}

// ===== 描述符类型相关谓词 =====

/**
 * 判断描述符类型是否有副作用的谓词函数
 * 技术上所有描述符获取都有副作用，但有些表示缺少调用，我们希望将它们视为没有效果。
 */
predicate side_effecting_descriptor_type(ClassValue descriptor) {
  descriptor.isDescriptorType() and
  // 排除一些常见的不产生副作用的描述符类型
  not descriptor = ClassValue::functionType() and
  not descriptor = ClassValue::staticmethod() and
  not descriptor = ClassValue::classmethod()
}

// ===== 二元运算符相关谓词 =====

/**
 * 有副作用的二元运算符很少见，所以我们假设它们没有副作用，除非我们知道它们有。
 */
predicate side_effecting_binary(Expr expr) {
  exists(Expr subExpr, ClassValue classValue, string methodName |
    binary_operator_special_method(expr, subExpr, classValue, methodName)
    or
    comparison_special_method(expr, subExpr, classValue, methodName)
  |
    methodName = special_method() and
    classValue.hasAttribute(methodName) and
    not exists(ClassValue declaring |
      declaring.declaresAttribute(methodName) and
      declaring = classValue.getASuperType() and
      declaring.isBuiltin() and
      not declaring = ClassValue::object()
    )
  )
}

/**
 * 获取二元运算符的特殊方法
 */
pragma[nomagic]
private predicate binary_operator_special_method(
  BinaryExpr binaryExpr, Expr subExpr, ClassValue classValue, string methodName
) {
  methodName = special_method() and
  subExpr = binaryExpr.getLeft() and
  methodName = binaryExpr.getOp().getSpecialMethodName() and
  subExpr.pointsTo().getClass() = classValue
}

/**
 * 获取比较运算符的特殊方法
 */
pragma[nomagic]
private predicate comparison_special_method(Compare compareExpr, Expr subExpr, ClassValue classValue, string methodName) {
  exists(Cmpop op |
    compareExpr.compares(subExpr, op, _) and
    methodName = op.getSpecialMethodName()
  ) and
  subExpr.pointsTo().getClass() = classValue
}

/**
 * 获取特殊方法名称
 */
private string special_method() {
  result = any(Cmpop c).getSpecialMethodName()
  or
  result = any(BinaryExpr b).getOp().getSpecialMethodName()
}

// ===== 环境相关谓词 =====

/**
 * 判断文件是否是Jupyter/IPython笔记本的谓词函数
 */
predicate is_notebook(File file) {
  exists(Comment comment | comment.getLocation().getFile() = file |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

/**
 * Jupyter/IPython笔记本中的表达式（语句）
 */
predicate in_notebook(Expr expr) { is_notebook(expr.getScope().(Module).getFile()) }

// ===== 测试相关谓词 =====

/**
 * 获取unittest.TestCase类中的assertRaises方法的FunctionValue对象
 */
FunctionValue assertRaises() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

/**
 * 如果表达式`expr`在测试异常引发的`with`块中，则成立。
 */
predicate in_raises_test(Expr expr) {
  exists(With withStmt |
    withStmt.contains(expr) and
    withStmt.getContextExpr() = assertRaises().getACall().getNode()
  )
}

// ===== Python 2 兼容性相关谓词 =====

/**
 * 如果表达式具有Python 2 `print >> out, ...`语句的形式，则成立
 */
predicate python2_print(Expr expr) {
  expr.(BinaryExpr).getLeft().(Name).getId() = "print" and
  expr.(BinaryExpr).getOp() instanceof RShift
  or
  python2_print(expr.(Tuple).getElt(0))
}

// ===== 主逻辑谓词 =====

/**
 * 判断表达式是否没有效果的谓词函数
 */
predicate no_effect(Expr expr) {
  // 字符串可以用作注释
  not expr instanceof StringLiteral and
  not expr.hasSideEffects() and
  forall(Expr subExpr | subExpr = expr.getASubExpression*() |
    not side_effecting_binary(subExpr) and
    not maybe_side_effecting_attribute(subExpr)
  ) and
  not in_notebook(expr) and
  not in_raises_test(expr) and
  not python2_print(expr)
}

// ===== 主查询 =====

/**
 * 从表达式语句中选择没有效果的语句并报告问题
 */
from ExprStmt exprStmt
where no_effect(exprStmt.getValue())
select exprStmt, "This statement has no effect."