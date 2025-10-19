/**
 * @name Statement has no effect
 * @description Identifies statements that do not produce any effect during program execution
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

// Helper predicates for descriptor analysis
/**
 * Determines if an attribute is properly defined by checking its source and target classes
 */
predicate attribute_is_well_defined(Attribute attr, ClassValue sourceClass, ClassValue attrClass) {
  exists(string attrName | attr.getName() = attrName |
    attr.getObject().pointsTo().getClass() = sourceClass and
    sourceClass.attr(attrName).getClass() = attrClass
  )
}

/**
 * Checks if a descriptor type access results in side effects
 */
predicate descriptor_type_has_side_effects(ClassValue descriptorClass) {
  descriptorClass.isDescriptorType() and
  // All descriptor accesses technically have side effects, but some represent missing calls
  // which we want to treat as having no effect
  not descriptorClass = ClassValue::functionType() and
  not descriptorClass = ClassValue::staticmethod() and
  not descriptorClass = ClassValue::classmethod()
}

/**
 * Conservatively assesses whether an attribute access might produce side effects
 */
predicate attribute_has_side_effects(Attribute attr) {
  exists(ClassValue attrClass |
    attribute_is_well_defined(attr, _, attrClass) and
    descriptor_type_has_side_effects(attrClass)
  )
}

/**
 * Identifies attributes that could potentially have side effects
 */
predicate attribute_might_have_side_effects(Attribute attr) {
  // Case 1: Attribute is not well-defined or doesn't point to a concrete value
  (not attribute_is_well_defined(attr, _, _) and not attr.pointsTo(_))
  or
  // Case 2: Attribute is already identified as having side effects
  attribute_has_side_effects(attr)
}

// Helper predicates for binary operator analysis
/**
 * Retrieves the special method name for comparison or binary operators
 */
private string get_special_method_name() {
  result = any(Cmpop comparisonOp).getSpecialMethodName()
  or
  result = any(BinaryExpr binaryExpr).getOp().getSpecialMethodName()
}

/**
 * Identifies binary expressions that utilize special operator methods
 */
pragma[nomagic]
private predicate is_special_binary_operator(
  BinaryExpr binaryExpr, Expr subExpr, ClassValue exprClass, string methodName
) {
  methodName = get_special_method_name() and
  subExpr = binaryExpr.getLeft() and
  methodName = binaryExpr.getOp().getSpecialMethodName() and
  subExpr.pointsTo().getClass() = exprClass
}

/**
 * Identifies comparison expressions that utilize special operator methods
 */
pragma[nomagic]
private predicate is_special_comparison_operator(Compare binaryExpr, Expr subExpr, ClassValue exprClass, string methodName) {
  exists(Cmpop op |
    binaryExpr.compares(subExpr, op, _) and
    methodName = op.getSpecialMethodName()
  ) and
  subExpr.pointsTo().getClass() = exprClass
}

/**
 * Binary operators with side effects are uncommon, so we assume they have no side effects
 * unless we have evidence to the contrary
 */
predicate binary_expr_has_side_effects(Expr binaryExpr) {
  exists(Expr subExpr, ClassValue exprClass, string methodName |
    // Handle binary operator special methods
    is_special_binary_operator(binaryExpr, subExpr, exprClass, methodName)
    or
    // Handle comparison operator special methods
    is_special_comparison_operator(binaryExpr, subExpr, exprClass, methodName)
  |
    methodName = get_special_method_name() and
    exprClass.hasAttribute(methodName) and
    // Exclude inherited methods from built-in types (except object)
    not exists(ClassValue declaring |
      declaring.declaresAttribute(methodName) and
      declaring = exprClass.getASuperType() and
      declaring.isBuiltin() and
      not declaring = ClassValue::object()
    )
  )
}

// Helper predicates for special context analysis
/**
 * Determines if a file is a Jupyter/IPython notebook
 */
predicate file_is_notebook(File notebookFile) {
  exists(Comment comment | comment.getLocation().getFile() = notebookFile |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

/**
 * Checks if an expression is within a Jupyter/IPython notebook
 */
predicate expression_in_notebook(Expr expr) { 
  file_is_notebook(expr.getScope().(Module).getFile()) 
}

/**
 * Retrieves the FunctionValue for unittest.TestCase's assertRaises method
 */
FunctionValue get_unittest_assert_raises_method() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

/**
 * Checks if an expression is within a `with` block that tests exception raising
 */
predicate expression_in_raises_test(Expr expr) {
  exists(With withStmt |
    withStmt.contains(expr) and
    withStmt.getContextExpr() = get_unittest_assert_raises_method().getACall().getNode()
  )
}

/**
 * Checks if an expression is a Python 2 print statement (e.g., print >> out, ...)
 */
predicate is_python2_print_expression(Expr expr) {
  // Handle print >> syntax
  (expr.(BinaryExpr).getLeft().(Name).getId() = "print" and
   expr.(BinaryExpr).getOp() instanceof RShift)
  or
  // Recursively handle first element in tuple
  is_python2_print_expression(expr.(Tuple).getElt(0))
}

// Main analysis predicate
/**
 * Determines if an expression has no effect by checking various conditions
 */
predicate expression_is_ineffectual(Expr expr) {
  // String literals can serve as comments
  not expr instanceof StringLiteral and
  not expr.hasSideEffects() and
  // Check all sub-expressions
  forall(Expr subExpr | subExpr = expr.getASubExpression*() |
    not binary_expr_has_side_effects(subExpr) and
    not attribute_might_have_side_effects(subExpr)
  ) and
  // Exclude special cases
  not expression_in_notebook(expr) and
  not expression_in_raises_test(expr) and
  not is_python2_print_expression(expr)
}

// Query execution
from ExprStmt stmt
where expression_is_ineffectual(stmt.getValue())
select stmt, "This statement has no effect."