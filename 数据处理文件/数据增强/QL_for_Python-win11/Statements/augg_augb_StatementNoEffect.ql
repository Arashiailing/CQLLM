/**
 * @name Statement has no effect
 * @description Identifies statements that have no effect on program execution
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

// Helper to retrieve special method names for operators and comparisons
private string operatorMethodName() {
  result = any(Cmpop c).getSpecialMethodName()
  or
  result = any(BinaryExpr b).getOp().getSpecialMethodName()
}

// Identifies special method invocations for binary operations
pragma[nomagic]
private predicate binaryOperatorMethod(
  BinaryExpr binaryExpr, Expr operand, ClassValue operandClass, string methodName
) {
  methodName = operatorMethodName() and
  operand = binaryExpr.getLeft() and
  methodName = binaryExpr.getOp().getSpecialMethodName() and
  operand.pointsTo().getClass() = operandClass
}

// Identifies special method invocations for comparison operations
pragma[nomagic]
private predicate comparisonOperatorMethod(
  Compare compareExpr, Expr operand, ClassValue operandClass, string methodName
) {
  exists(Cmpop op |
    compareExpr.compares(operand, op, _) and
    methodName = op.getSpecialMethodName()
  ) and
  operand.pointsTo().getClass() = operandClass
}

// Determines if a descriptor type has side effects during access
predicate sideEffectingDescriptor(ClassValue descriptorType) {
  descriptorType.isDescriptorType() and
  // Exclude descriptor types that represent missing method calls
  not descriptorType = ClassValue::functionType() and
  not descriptorType = ClassValue::staticmethod() and
  not descriptorType = ClassValue::classmethod()
}

// Checks if an attribute is resolved to specific owner and attribute classes
predicate resolvedAttribute(Attribute attr, ClassValue ownerClass, ClassValue attrClass) {
  exists(string attrName | attr.getName() = attrName |
    attr.getObject().pointsTo().getClass() = ownerClass and
    ownerClass.attr(attrName).getClass() = attrClass
  )
}

// Determines if an attribute access has side effects
predicate sideEffectingAttrAccess(Attribute attr) {
  exists(ClassValue attrClass |
    resolvedAttribute(attr, _, attrClass) and
    sideEffectingDescriptor(attrClass)
  )
}

// Checks if an attribute might have side effects (unresolved or descriptor)
predicate potentialSideEffectingAttr(Attribute attr) {
  not resolvedAttribute(attr, _, _) and not attr.pointsTo(_)
  or
  sideEffectingAttrAccess(attr)
}

// Determines if a binary operation might have side effects through special methods
predicate sideEffectingBinaryOp(Expr binaryExpr) {
  exists(Expr operand, ClassValue operandClass, string methodName |
    binaryOperatorMethod(binaryExpr, operand, operandClass, methodName)
    or
    comparisonOperatorMethod(binaryExpr, operand, operandClass, methodName)
  |
    methodName = operatorMethodName() and
    operandClass.hasAttribute(methodName) and
    // Exclude built-in methods from object hierarchy
    not exists(ClassValue declaring |
      declaring.declaresAttribute(methodName) and
      declaring = operandClass.getASuperType() and
      declaring.isBuiltin() and
      not declaring = ClassValue::object()
    )
  )
}

// Checks if a file is a Jupyter/IPython notebook
predicate isNotebookFile(File file) {
  exists(Comment comment | comment.getLocation().getFile() = file |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

// Checks if an expression is within a Jupyter/IPython notebook
predicate inNotebookContext(Expr expr) { 
  isNotebookFile(expr.getScope().(Module).getFile()) 
}

// Retrieves the unittest.TestCase.assertRaises method
FunctionValue unittestAssertRaises() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

// Checks if an expression is within a test for exception raising
predicate inExceptionTest(Expr expr) {
  exists(With withBlock |
    withBlock.contains(expr) and
    withBlock.getContextExpr() = unittestAssertRaises().getACall().getNode()
  )
}

// Checks if an expression is a Python 2 print statement
predicate isPython2Print(Expr expr) {
  expr.(BinaryExpr).getLeft().(Name).getId() = "print" and
  expr.(BinaryExpr).getOp() instanceof RShift
  or
  isPython2Print(expr.(Tuple).getElt(0))
}

// Determines if an expression has no effect on program state
predicate hasNoEffect(Expr expr) {
  // Exclude string literals (used as docstrings/comments)
  not expr instanceof StringLiteral and
  // Base check for side effects
  not expr.hasSideEffects() and
  // Verify all sub-expressions lack side effects
  forall(Expr subExpr | subExpr = expr.getASubExpression*() |
    not sideEffectingBinaryOp(subExpr) and
    not potentialSideEffectingAttr(subExpr)
  ) and
  // Exclude special contexts where expressions are intentionally unevaluated
  not inNotebookContext(expr) and
  not inExceptionTest(expr) and
  not isPython2Print(expr)
}

// Main query to identify statements with no effect
from ExprStmt stmt
where hasNoEffect(stmt.getValue())
select stmt, "This statement has no effect."