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

// ===== 属性解析相关谓词 =====

/**
 * 确定属性引用是否可被解析的谓词
 * 验证属性是否属于特定类，以及该属性的类是否可确定
 */
predicate understood_attribute(Attribute attrRef, ClassValue typeValue, ClassValue attrType) {
  exists(string attrName | attrRef.getName() = attrName |
    attrRef.getObject().pointsTo().getClass() = typeValue and
    typeValue.attr(attrName).getClass() = attrType
  )
}

/**
 * 保守判断属性访问是否产生副作用
 * 当属性可被解析且其描述符类型有副作用时，认为该属性访问有副作用
 */
predicate side_effecting_attribute(Attribute attrRef) {
  exists(ClassValue attrType |
    understood_attribute(attrRef, _, attrType) and
    side_effecting_descriptor_type(attrType)
  )
}

/**
 * 判断属性访问是否可能产生副作用
 * 如果属性无法解析或不指向任何值，或者已知有副作用，则认为可能有副作用
 */
predicate maybe_side_effecting_attribute(Attribute attrRef) {
  not understood_attribute(attrRef, _, _) and not attrRef.pointsTo(_)
  or
  side_effecting_attribute(attrRef)
}

// ===== 描述符类型相关谓词 =====

/**
 * 判断描述符类型是否有副作用
 * 技术上，所有描述符获取都有副作用，但某些情况代表缺少调用，我们将其视为无效果
 */
predicate side_effecting_descriptor_type(ClassValue descriptor) {
  descriptor.isDescriptorType() and
  // 排除常见的无副作用描述符类型
  not descriptor = ClassValue::functionType() and
  not descriptor = ClassValue::staticmethod() and
  not descriptor = ClassValue::classmethod()
}

// ===== 二元操作相关谓词 =====

/**
 * 有副作用的二元操作很少见，因此我们假设它们没有副作用，除非明确知道有副作用
 */
predicate side_effecting_binary(Expr expression) {
  exists(Expr subExpression, ClassValue typeValue, string methodIdentifier |
    binary_operator_special_method(expression, subExpression, typeValue, methodIdentifier)
    or
    comparison_special_method(expression, subExpression, typeValue, methodIdentifier)
  |
    methodIdentifier = special_method() and
    typeValue.hasAttribute(methodIdentifier) and
    not exists(ClassValue declaring |
      declaring.declaresAttribute(methodIdentifier) and
      declaring = typeValue.getASuperType() and
      declaring.isBuiltin() and
      not declaring = ClassValue::object()
    )
  )
}

/**
 * 获取二元操作的特殊方法
 */
pragma[nomagic]
private predicate binary_operator_special_method(
  BinaryExpr binaryOperation, Expr subExpression, ClassValue typeValue, string methodIdentifier
) {
  methodIdentifier = special_method() and
  subExpression = binaryOperation.getLeft() and
  methodIdentifier = binaryOperation.getOp().getSpecialMethodName() and
  subExpression.pointsTo().getClass() = typeValue
}

/**
 * 获取比较操作的特殊方法
 */
pragma[nomagic]
private predicate comparison_special_method(Compare comparisonOperation, Expr subExpression, ClassValue typeValue, string methodIdentifier) {
  exists(Cmpop op |
    comparisonOperation.compares(subExpression, op, _) and
    methodIdentifier = op.getSpecialMethodName()
  ) and
  subExpression.pointsTo().getClass() = typeValue
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
 * 判断源文件是否为Jupyter/IPython笔记本
 */
predicate is_notebook(File sourceFile) {
  exists(Comment codeComment | codeComment.getLocation().getFile() = sourceFile |
    codeComment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

/**
 * 判断表达式是否位于Jupyter/IPython笔记本中
 */
predicate in_notebook(Expr expression) { is_notebook(expression.getScope().(Module).getFile()) }

// ===== 测试相关谓词 =====

/**
 * 获取unittest.TestCase类中的assertRaises方法的FunctionValue对象
 */
FunctionValue assertRaises() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

/**
 * 判断表达式是否位于测试异常引发的with块中
 */
predicate in_raises_test(Expr expression) {
  exists(With withStatement |
    withStatement.contains(expression) and
    withStatement.getContextExpr() = assertRaises().getACall().getNode()
  )
}

// ===== Python 2 兼容性相关谓词 =====

/**
 * 判断表达式是否具有Python 2 `print >> out, ...`语句的形式
 */
predicate python2_print(Expr expression) {
  expression.(BinaryExpr).getLeft().(Name).getId() = "print" and
  expression.(BinaryExpr).getOp() instanceof RShift
  or
  python2_print(expression.(Tuple).getElt(0))
}

// ===== 主逻辑谓词 =====

/**
 * 判断表达式是否没有效果
 */
predicate no_effect(Expr expression) {
  // 字符串可以作为注释使用
  not expression instanceof StringLiteral and
  not expression.hasSideEffects() and
  forall(Expr subExpression | subExpression = expression.getASubExpression*() |
    not side_effecting_binary(subExpression) and
    not maybe_side_effecting_attribute(subExpression)
  ) and
  not in_notebook(expression) and
  not in_raises_test(expression) and
  not python2_print(expression)
}

// ===== 主查询 =====

/**
 * 选择没有效果的语句表达式并报告问题
 */
from ExprStmt expressionStatement
where no_effect(expressionStatement.getValue())
select expressionStatement, "This statement has no effect."