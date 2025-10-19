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

// Determines if an attribute access is well-understood by analyzing its type information
predicate is_understood_attribute(Attribute attrNode, ClassValue sourceCls, ClassValue attrCls) {
  exists(string attrName | attrNode.getName() = attrName |
    attrNode.getObject().pointsTo().getClass() = sourceCls and
    sourceCls.attr(attrName).getClass() = attrCls
  )
}

/* Conservative check for side effects in attribute access */
predicate is_side_effecting_attribute(Attribute attrNode) {
  exists(ClassValue attrCls |
    is_understood_attribute(attrNode, _, attrCls) and
    is_side_effecting_descriptor_type(attrCls)
  )
}

// Identifies attributes that may have side effects
predicate is_maybe_side_effecting_attribute(Attribute attrNode) {
  not is_understood_attribute(attrNode, _, _) and not attrNode.pointsTo(_)
  or
  is_side_effecting_attribute(attrNode)
}

// Determines if a descriptor type has side effects
predicate is_side_effecting_descriptor_type(ClassValue descriptorCls) {
  descriptorCls.isDescriptorType() and
  // While all descriptor accesses technically have side effects, 
  // some represent missing calls and should be treated as effectless
  not descriptorCls = ClassValue::functionType() and
  not descriptorCls = ClassValue::staticmethod() and
  not descriptorCls = ClassValue::classmethod()
}

// Helper to get special method names for operators
private string get_special_method_name() {
  result = any(Cmpop c).getSpecialMethodName()
  or
  result = any(BinaryExpr b).getOp().getSpecialMethodName()
}

pragma[nomagic]
private predicate is_binary_operator_special_method(
  BinaryExpr binaryExpr, Expr subExpr, ClassValue sourceCls, string methodName
) {
  methodName = get_special_method_name() and
  subExpr = binaryExpr.getLeft() and
  methodName = binaryExpr.getOp().getSpecialMethodName() and
  subExpr.pointsTo().getClass() = sourceCls
}

pragma[nomagic]
private predicate is_comparison_special_method(Compare comparisonExpr, Expr subExpr, ClassValue sourceCls, string methodName) {
  exists(Cmpop op |
    comparisonExpr.compares(subExpr, op, _) and
    methodName = op.getSpecialMethodName()
  ) and
  subExpr.pointsTo().getClass() = sourceCls
}

/**
 * Binary operators rarely have side effects, so we assume they don't
 * unless we have evidence to the contrary
 */
predicate is_side_effecting_binary(Expr binaryExpr) {
  exists(Expr subExpr, ClassValue sourceCls, string methodName |
    is_binary_operator_special_method(binaryExpr, subExpr, sourceCls, methodName)
    or
    is_comparison_special_method(binaryExpr, subExpr, sourceCls, methodName)
  |
    methodName = get_special_method_name() and
    sourceCls.hasAttribute(methodName) and
    not exists(ClassValue declaring |
      declaring.declaresAttribute(methodName) and
      declaring = sourceCls.getASuperType() and
      declaring.isBuiltin() and
      not declaring = ClassValue::object()
    )
  )
}

// Checks if a file is a Jupyter/IPython notebook
predicate is_notebook_file(File file) {
  exists(Comment comment | comment.getLocation().getFile() = file |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

/** Identifies expressions within Jupyter/IPython notebooks */
predicate is_in_notebook(Expr expression) { 
  is_notebook_file(expression.getScope().(Module).getFile()) 
}

// Retrieves the unittest.TestCase.assertRaises method
FunctionValue get_unittest_assert_raises() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

/** Checks if an expression is within a test for exception raising */
predicate is_in_raises_test(Expr expression) {
  exists(With withStmt |
    withStmt.contains(expression) and
    withStmt.getContextExpr() = get_unittest_assert_raises().getACall().getNode()
  )
}

/** Identifies Python 2 print statements with redirection */
predicate is_python2_print(Expr expression) {
  expression.(BinaryExpr).getLeft().(Name).getId() = "print" and
  expression.(BinaryExpr).getOp() instanceof RShift
  or
  is_python2_print(expression.(Tuple).getElt(0))
}

// Determines if an expression has no effect
predicate is_no_effect_expression(Expr expression) {
  // Strings can serve as documentation
  (not expression instanceof StringLiteral and not expression.hasSideEffects()) and
  // Verify all sub-expressions are side-effect free
  forall(Expr subExpr | subExpr = expression.getASubExpression*() |
    (not is_side_effecting_binary(subExpr) and not is_maybe_side_effecting_attribute(subExpr))
  ) and
  // Exclude special contexts where effectless expressions are allowed
  (not is_in_notebook(expression) and not is_in_raises_test(expression) and not is_python2_print(expression))
}

// Select expression statements with no effect and report issues
from ExprStmt statement
where is_no_effect_expression(statement.getValue())
select statement, "This statement has no effect."