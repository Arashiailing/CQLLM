/**
 * @name Statement has no effect
 * @description Identifies statements that have no effect (dead code)
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

// Helper to determine if an attribute access is well-understood
predicate is_well_understood_attr(Attribute attrAccess, ClassValue sourceClass, ClassValue attrClass) {
  exists(string attrName | attrAccess.getName() = attrName |
    attrAccess.getObject().pointsTo().getClass() = sourceClass and
    sourceClass.attr(attrName).getClass() = attrClass
  )
}

// Conservative check for side-effecting attribute access
predicate is_side_effecting_attr(Attribute attrAccess) {
  exists(ClassValue attrClass |
    is_well_understood_attr(attrAccess, _, attrClass) and
    is_side_effecting_descriptor_type(attrClass)
  )
}

// Check for potentially side-effecting attribute access
predicate is_potentially_side_effecting_attr(Attribute attrAccess) {
  not is_well_understood_attr(attrAccess, _, _) and not attrAccess.pointsTo(_)
  or
  is_side_effecting_attr(attrAccess)
}

// Determine if a descriptor type has side effects
predicate is_side_effecting_descriptor_type(ClassValue descriptorClass) {
  descriptorClass.isDescriptorType() and
  // Technically all descriptor accesses have side effects, but we exclude common harmless ones
  not descriptorClass = ClassValue::functionType() and
  not descriptorClass = ClassValue::staticmethod() and
  not descriptorClass = ClassValue::classmethod()
}

// Get special method names for operators and comparisons
private string get_special_method_name() {
  result = any(Cmpop c).getSpecialMethodName()
  or
  result = any(BinaryExpr b).getOp().getSpecialMethodName()
}

pragma[nomagic]
private predicate is_bin_op_special_method(
  BinaryExpr binaryExpr, Expr subExpression, ClassValue sourceClass, string specialMethodName
) {
  specialMethodName = get_special_method_name() and
  subExpression = binaryExpr.getLeft() and
  specialMethodName = binaryExpr.getOp().getSpecialMethodName() and
  subExpression.pointsTo().getClass() = sourceClass
}

pragma[nomagic]
private predicate is_cmp_special_method(
  Compare comparisonExpr, Expr subExpression, ClassValue sourceClass, string specialMethodName
) {
  exists(Cmpop op |
    comparisonExpr.compares(subExpression, op, _) and
    specialMethodName = op.getSpecialMethodName()
  ) and
  subExpression.pointsTo().getClass() = sourceClass
}

/**
 * Most binary operations are side-effect free, but we check for exceptions
 */
predicate is_side_effecting_binary(Expr binaryExpr) {
  exists(Expr subExpression, ClassValue sourceClass, string specialMethodName |
    is_bin_op_special_method(binaryExpr, subExpression, sourceClass, specialMethodName)
    or
    is_cmp_special_method(binaryExpr, subExpression, sourceClass, specialMethodName)
  |
    specialMethodName = get_special_method_name() and
    sourceClass.hasAttribute(specialMethodName) and
    not exists(ClassValue declaring |
      declaring.declaresAttribute(specialMethodName) and
      declaring = sourceClass.getASuperType() and
      declaring.isBuiltin() and
      not declaring = ClassValue::object()
    )
  )
}

// Check if file is a Jupyter/IPython notebook
predicate is_notebook_file(File sourceFile) {
  exists(Comment notebookComment | notebookComment.getLocation().getFile() = sourceFile |
    notebookComment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

/** Check if expression is in a Jupyter/IPython notebook */
predicate is_in_notebook(Expr expression) { 
  is_notebook_file(expression.getScope().(Module).getFile()) 
}

// Get unittest.TestCase's assertRaises method
FunctionValue get_unittest_assert_raises() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

/** Check if expression is in a unittest assertRaises context */
predicate is_in_raises_test(Expr expression) {
  exists(With withStatement |
    withStatement.contains(expression) and
    withStatement.getContextExpr() = get_unittest_assert_raises().getACall().getNode()
  )
}

/** Check for Python 2 print statements (print >> out, ...) */
predicate is_python2_print(Expr expression) {
  expression.(BinaryExpr).getLeft().(Name).getId() = "print" and
  expression.(BinaryExpr).getOp() instanceof RShift
  or
  is_python2_print(expression.(Tuple).getElt(0))
}

// Core predicate to identify expressions with no effect
predicate is_no_effect_expression(Expr expression) {
  // Strings can be used as docstrings/comments
  (not expression instanceof StringLiteral and not expression.hasSideEffects()) and
  // Ensure all sub-expressions are side-effect free
  forall(Expr subExpression | subExpression = expression.getASubExpression*() |
    (not is_side_effecting_binary(subExpression) and not is_potentially_side_effecting_attr(subExpression))
  ) and
  // Exclude special contexts where expressions are expected
  (not is_in_notebook(expression) and not is_in_raises_test(expression) and not is_python2_print(expression))
}

// Main query to find and report ineffectual statements
from ExprStmt statement
where is_no_effect_expression(statement.getValue())
select statement, "This statement has no effect."