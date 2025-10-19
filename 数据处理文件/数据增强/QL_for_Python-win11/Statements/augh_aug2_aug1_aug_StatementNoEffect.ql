/**
 * @name Statement has no effect
 * @description Identifies statements that produce no observable effect during program execution
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

/* Determines if an attribute access has well-defined source and target classes */
predicate is_attribute_understood(Attribute attr, ClassValue sourceClass, ClassValue attrClass) {
  exists(string attrName | attr.getName() = attrName |
    attr.getObject().pointsTo().getClass() = sourceClass and
    sourceClass.attr(attrName).getClass() = attrClass
  )
}

/* Identifies attributes that could potentially have side effects */
predicate might_have_side_effect_attr(Attribute attr) {
  // Case 1: Attribute is not understood or doesn't point to a concrete value
  (not is_attribute_understood(attr, _, _) and not attr.pointsTo(_))
  or
  // Case 2: Attribute is already identified as having side effects
  has_side_effecting_attr(attr)
}

/* Checks if a descriptor type has side effects when accessed */
predicate is_descriptor_type_side_effecting(ClassValue descClass) {
  descClass.isDescriptorType() and
  // All descriptor accesses have side effects, but some represent missing calls
  // which we treat as having no effect
  not descClass = ClassValue::functionType() and
  not descClass = ClassValue::staticmethod() and
  not descClass = ClassValue::classmethod()
}

/* Conservatively determines if an attribute access could have side effects */
predicate has_side_effecting_attr(Attribute attr) {
  exists(ClassValue attrClass |
    is_attribute_understood(attr, _, attrClass) and
    is_descriptor_type_side_effecting(attrClass)
  )
}

/**
 * Binary operators with side effects are uncommon, so we assume they have no side effects
 * unless we have evidence to the contrary
 */
predicate is_binary_side_effecting(Expr binaryExpr) {
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

// Retrieves the special method name for comparison or binary operators
private string get_special_method_name() {
  result = any(Cmpop comparisonOp).getSpecialMethodName()
  or
  result = any(BinaryExpr binaryExpr).getOp().getSpecialMethodName()
}

// Identifies binary expressions that use special operator methods
pragma[nomagic]
private predicate is_special_binary_operator(
  BinaryExpr binaryExpr, Expr subExpr, ClassValue exprClass, string methodName
) {
  methodName = get_special_method_name() and
  subExpr = binaryExpr.getLeft() and
  methodName = binaryExpr.getOp().getSpecialMethodName() and
  subExpr.pointsTo().getClass() = exprClass
}

// Identifies comparison expressions that use special operator methods
pragma[nomagic]
private predicate is_special_comparison_operator(Compare binaryExpr, Expr subExpr, ClassValue exprClass, string methodName) {
  exists(Cmpop op |
    binaryExpr.compares(subExpr, op, _) and
    methodName = op.getSpecialMethodName()
  ) and
  subExpr.pointsTo().getClass() = exprClass
}

// Determines if a file is a Jupyter/IPython notebook
predicate is_notebook_file(File file) {
  exists(Comment cmt | cmt.getLocation().getFile() = file |
    cmt.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

// Checks if an expression is within a Jupyter/IPython notebook
predicate expr_in_notebook(Expr expr) { 
  is_notebook_file(expr.getScope().(Module).getFile()) 
}

// Retrieves the FunctionValue for unittest.TestCase's assertRaises method
FunctionValue get_assert_raises_method() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

// Checks if an expression is within a `with` block that tests exception raising
predicate expr_in_raises_test(Expr expr) {
  exists(With withStmt |
    withStmt.contains(expr) and
    withStmt.getContextExpr() = get_assert_raises_method().getACall().getNode()
  )
}

// Checks if an expression is a Python 2 print statement (e.g., print >> out, ...)
predicate is_python2_print_stmt(Expr expr) {
  // Handle print >> syntax
  (expr.(BinaryExpr).getLeft().(Name).getId() = "print" and
   expr.(BinaryExpr).getOp() instanceof RShift)
  or
  // Recursively handle first element in tuple
  is_python2_print_stmt(expr.(Tuple).getElt(0))
}

// Determines if an expression has no effect
predicate expression_has_no_effect(Expr expr) {
  // String literals can serve as comments
  not expr instanceof StringLiteral and
  not expr.hasSideEffects() and
  // Check all sub-expressions
  forall(Expr subExpr | subExpr = expr.getASubExpression*() |
    not is_binary_side_effecting(subExpr) and
    not might_have_side_effect_attr(subExpr)
  ) and
  // Exclude special cases
  not expr_in_notebook(expr) and
  not expr_in_raises_test(expr) and
  not is_python2_print_stmt(expr)
}

// Select statements with no effect and report the issue
from ExprStmt stmt
where expression_has_no_effect(stmt.getValue())
select stmt, "This statement has no effect."