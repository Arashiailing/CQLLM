/**
 * @name Statement has no effect
 * @description Identifies statements that have no effect, which may indicate dead code or programming errors
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

// ===== OPERATOR METHOD NAME HELPERS =====

// Helper to determine special method names for operators
private string getSpecialOperatorMethodName() {
  result = any(Cmpop cmpOp).getSpecialMethodName()
  or
  result = any(BinaryExpr binExpr).getOp().getSpecialMethodName()
}

// ===== OPERATOR SPECIAL METHOD DETECTION =====

// Identifies special methods for binary operators
pragma[nomagic]
private predicate binaryOperatorSpecialMethod(
  BinaryExpr binaryExpr, Expr subExpr, ClassValue exprClass, string methodName
) {
  methodName = getSpecialOperatorMethodName() and
  subExpr = binaryExpr.getLeft() and
  methodName = binaryExpr.getOp().getSpecialMethodName() and
  subExpr.pointsTo().getClass() = exprClass
}

// Identifies special methods for comparison operations
pragma[nomagic]
private predicate comparisonOperatorSpecialMethod(
  Compare compareExpr, Expr subExpr, ClassValue exprClass, string methodName
) {
  exists(Cmpop op |
    compareExpr.compares(subExpr, op, _) and
    methodName = op.getSpecialMethodName()
  ) and
  subExpr.pointsTo().getClass() = exprClass
}

// ===== DESCRIPTOR AND ATTRIBUTE ANALYSIS =====

// Determines if a descriptor type has side effects
predicate hasSideEffectingDescriptorType(ClassValue descriptorType) {
  descriptorType.isDescriptorType() and
  // All descriptor accesses technically have side effects, but some represent missing calls
  // that we want to treat as having no effect
  not descriptorType = ClassValue::functionType() and
  not descriptorType = ClassValue::staticmethod() and
  not descriptorType = ClassValue::classmethod()
}

// Checks if an attribute is understood (resolved to specific classes)
predicate isUnderstoodAttribute(Attribute attrNode, ClassValue ownerClass, ClassValue attrClass) {
  exists(string attrName | attrNode.getName() = attrName |
    attrNode.getObject().pointsTo().getClass() = ownerClass and
    ownerClass.attr(attrName).getClass() = attrClass
  )
}

// Determines if an attribute access has side effects
predicate hasSideEffectingAttribute(Attribute attrNode) {
  exists(ClassValue attrClass |
    isUnderstoodAttribute(attrNode, _, attrClass) and
    hasSideEffectingDescriptorType(attrClass)
  )
}

// Checks if an attribute might have side effects
predicate mightHaveSideEffectingAttribute(Attribute attrNode) {
  not isUnderstoodAttribute(attrNode, _, _) and not attrNode.pointsTo(_)
  or
  hasSideEffectingAttribute(attrNode)
}

// ===== BINARY OPERATION SIDE EFFECT ANALYSIS =====

// Determines if a binary operation has side effects
predicate hasSideEffectingBinaryOperation(Expr binaryExpr) {
  exists(Expr subExpr, ClassValue exprClass, string methodName |
    binaryOperatorSpecialMethod(binaryExpr, subExpr, exprClass, methodName)
    or
    comparisonOperatorSpecialMethod(binaryExpr, subExpr, exprClass, methodName)
  |
    methodName = getSpecialOperatorMethodName() and
    exprClass.hasAttribute(methodName) and
    not exists(ClassValue declaring |
      declaring.declaresAttribute(methodName) and
      declaring = exprClass.getASuperType() and
      declaring.isBuiltin() and
      not declaring = ClassValue::object()
    )
  )
}

// ===== SPECIAL CONTEXT DETECTION =====

// Checks if a file is a Jupyter/IPython notebook
predicate isJupyterNotebook(File file) {
  exists(Comment comment | comment.getLocation().getFile() = file |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

// Checks if an expression is in a Jupyter/IPython notebook
predicate isExpressionInNotebook(Expr expr) { 
  isJupyterNotebook(expr.getScope().(Module).getFile()) 
}

// Gets the unittest.TestCase.assertRaises method
FunctionValue getAssertRaisesMethod() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

// Checks if an expression is in a test for exception raising
predicate isInRaisesTest(Expr expr) {
  exists(With withBlock |
    withBlock.contains(expr) and
    withBlock.getContextExpr() = getAssertRaisesMethod().getACall().getNode()
  )
}

// Checks if an expression is a Python 2 print statement
predicate isPython2PrintStatement(Expr expr) {
  expr.(BinaryExpr).getLeft().(Name).getId() = "print" and
  expr.(BinaryExpr).getOp() instanceof RShift
  or
  isPython2PrintStatement(expr.(Tuple).getElt(0))
}

// ===== MAIN EFFECT ANALYSIS =====

// Determines if an expression has no effect
predicate hasNoEffect(Expr expr) {
  // Strings can be used as docstrings/comments
  not expr instanceof StringLiteral and
  not expr.hasSideEffects() and
  // Check all sub-expressions for side effects
  forall(Expr subExpr | subExpr = expr.getASubExpression*() |
    not hasSideEffectingBinaryOperation(subExpr) and
    not mightHaveSideEffectingAttribute(subExpr)
  ) and
  // Exclude special contexts where expressions are expected
  not isExpressionInNotebook(expr) and
  not isInRaisesTest(expr) and
  not isPython2PrintStatement(expr)
}

// ===== MAIN QUERY =====

// Main query to find statements with no effect
from ExprStmt stmt
where hasNoEffect(stmt.getValue())
select stmt, "This statement has no effect."