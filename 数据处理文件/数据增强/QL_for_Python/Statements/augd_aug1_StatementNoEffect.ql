/**
 * @name Statement has no effect
 * @description Identifies statements that produce no observable effect
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

// Determines if an attribute access is fully understood by the type system
predicate is_comprehended_attribute(Attribute attrNode, ClassValue srcClass, ClassValue attrClass) {
  exists(string attrName | attrNode.getName() = attrName |
    attrNode.getObject().pointsTo().getClass() = srcClass and
    srcClass.attr(attrName).getClass() = attrClass
  )
}

// Checks if an attribute access has potential side effects
predicate is_side_effecting_attr(Attribute attrNode) {
  exists(ClassValue attrClass |
    is_comprehended_attribute(attrNode, _, attrClass) and
    is_side_effecting_descriptor_type(attrClass)
  )
}

// Determines if an attribute might have side effects
predicate is_potentially_side_effecting_attr(Attribute attrNode) {
  not is_comprehended_attribute(attrNode, _, _) and not attrNode.pointsTo(_)
  or
  is_side_effecting_attr(attrNode)
}

// Identifies descriptor types that may have side effects
predicate is_side_effecting_descriptor_type(ClassValue descriptorClass) {
  descriptorClass.isDescriptorType() and
  // All descriptor accesses technically have side effects, but we exclude common safe cases
  not descriptorClass = ClassValue::functionType() and
  not descriptorClass = ClassValue::staticmethod() and
  not descriptorClass = ClassValue::classmethod()
}

// Retrieves special method names for operators
private string get_special_method_name() {
  result = any(Cmpop c).getSpecialMethodName()
  or
  result = any(BinaryExpr b).getOp().getSpecialMethodName()
}

pragma[nomagic]
private predicate has_binary_special_method(
  BinaryExpr binaryExpr, Expr subExpr, ClassValue srcClass, string methodName
) {
  methodName = get_special_method_name() and
  subExpr = binaryExpr.getLeft() and
  methodName = binaryExpr.getOp().getSpecialMethodName() and
  subExpr.pointsTo().getClass() = srcClass
}

pragma[nomagic]
private predicate has_comparison_special_method(Compare compExpr, Expr subExpr, ClassValue srcClass, string methodName) {
  exists(Cmpop op |
    compExpr.compares(subExpr, op, _) and
    methodName = op.getSpecialMethodName()
  ) and
  subExpr.pointsTo().getClass() = srcClass
}

/**
 * Side-effecting binary operators are rare. We assume no side effects unless proven otherwise.
 */
predicate is_side_effecting_binary(Expr binaryExpr) {
  exists(Expr subExpr, ClassValue srcClass, string methodName |
    has_binary_special_method(binaryExpr, subExpr, srcClass, methodName)
    or
    has_comparison_special_method(binaryExpr, subExpr, srcClass, methodName)
  |
    methodName = get_special_method_name() and
    srcClass.hasAttribute(methodName) and
    not exists(ClassValue declaring |
      declaring.declaresAttribute(methodName) and
      declaring = srcClass.getASuperType() and
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

// Identifies expressions within Jupyter/IPython notebooks
predicate is_in_notebook_context(Expr expr) { 
  is_notebook_file(expr.getScope().(Module).getFile()) 
}

// Retrieves unittest.TestCase's assertRaises method
FunctionValue get_unittest_assert_raises() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

// Checks if an expression is within an exception-testing context
predicate is_in_exception_test(Expr expr) {
  exists(With withStmt |
    withStmt.contains(expr) and
    withStmt.getContextExpr() = get_unittest_assert_raises().getACall().getNode()
  )
}

// Identifies Python 2 print statements (e.g., print >> out, ...)
predicate is_python2_print_stmt(Expr expr) {
  expr.(BinaryExpr).getLeft().(Name).getId() = "print" and
  expr.(BinaryExpr).getOp() instanceof RShift
  or
  is_python2_print_stmt(expr.(Tuple).getElt(0))
}

// Core predicate to determine if an expression has no effect
predicate is_no_effect_expression(Expr expr) {
  // Exclude string literals which can serve as comments
  (not expr instanceof StringLiteral and not expr.hasSideEffects()) and
  // Verify all sub-expressions are side-effect free
  forall(Expr subExpr | subExpr = expr.getASubExpression*() |
    (not is_side_effecting_binary(subExpr) and not is_potentially_side_effecting_attr(subExpr))
  ) and
  // Exclude special contexts where expressions are intentionally no-op
  (not is_in_notebook_context(expr) and 
   not is_in_exception_test(expr) and 
   not is_python2_print_stmt(expr))
}

// Query to identify and report ineffectual statements
from ExprStmt statement
where is_no_effect_expression(statement.getValue())
select statement, "This statement has no effect."