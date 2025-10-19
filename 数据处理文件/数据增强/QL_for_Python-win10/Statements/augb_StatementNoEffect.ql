/**
 * @name Statement has no effect
 * @description Detects statements that have no effect
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

// Helper to determine special method names for operators
private string specialMethodName() {
  result = any(Cmpop c).getSpecialMethodName()
  or
  result = any(BinaryExpr b).getOp().getSpecialMethodName()
}

// Identifies special methods for binary operators
pragma[nomagic]
private predicate binaryOperatorSpecialMethod(
  BinaryExpr binaryExpr, Expr subExpr, ClassValue exprClass, string methodName
) {
  methodName = specialMethodName() and
  subExpr = binaryExpr.getLeft() and
  methodName = binaryExpr.getOp().getSpecialMethodName() and
  subExpr.pointsTo().getClass() = exprClass
}

// Identifies special methods for comparison operations
pragma[nomagic]
private predicate comparisonSpecialMethod(
  Compare compareExpr, Expr subExpr, ClassValue exprClass, string methodName
) {
  exists(Cmpop op |
    compareExpr.compares(subExpr, op, _) and
    methodName = op.getSpecialMethodName()
  ) and
  subExpr.pointsTo().getClass() = exprClass
}

// Determines if a descriptor type has side effects
predicate sideEffectingDescriptorType(ClassValue descriptorType) {
  descriptorType.isDescriptorType() and
  // All descriptor accesses technically have side effects, but some represent missing calls
  // that we want to treat as having no effect
  not descriptorType = ClassValue::functionType() and
  not descriptorType = ClassValue::staticmethod() and
  not descriptorType = ClassValue::classmethod()
}

// Checks if an attribute is understood (resolved to specific classes)
predicate understoodAttribute(Attribute attrNode, ClassValue ownerClass, ClassValue attrClass) {
  exists(string attrName | attrNode.getName() = attrName |
    attrNode.getObject().pointsTo().getClass() = ownerClass and
    ownerClass.attr(attrName).getClass() = attrClass
  )
}

// Determines if an attribute access has side effects
predicate sideEffectingAttribute(Attribute attrNode) {
  exists(ClassValue attrClass |
    understoodAttribute(attrNode, _, attrClass) and
    sideEffectingDescriptorType(attrClass)
  )
}

// Checks if an attribute might have side effects
predicate maybeSideEffectingAttribute(Attribute attrNode) {
  not understoodAttribute(attrNode, _, _) and not attrNode.pointsTo(_)
  or
  sideEffectingAttribute(attrNode)
}

// Determines if a binary operation has side effects
predicate sideEffectingBinary(Expr binaryExpr) {
  exists(Expr subExpr, ClassValue exprClass, string methodName |
    binaryOperatorSpecialMethod(binaryExpr, subExpr, exprClass, methodName)
    or
    comparisonSpecialMethod(binaryExpr, subExpr, exprClass, methodName)
  |
    methodName = specialMethodName() and
    exprClass.hasAttribute(methodName) and
    not exists(ClassValue declaring |
      declaring.declaresAttribute(methodName) and
      declaring = exprClass.getASuperType() and
      declaring.isBuiltin() and
      not declaring = ClassValue::object()
    )
  )
}

// Checks if a file is a Jupyter/IPython notebook
predicate isNotebook(File file) {
  exists(Comment comment | comment.getLocation().getFile() = file |
    comment.getText().regexpMatch("#\\s*<nbformat>.+</nbformat>\\s*")
  )
}

// Checks if an expression is in a Jupyter/IPython notebook
predicate inNotebook(Expr expr) { 
  isNotebook(expr.getScope().(Module).getFile()) 
}

// Gets the unittest.TestCase.assertRaises method
FunctionValue assertRaisesMethod() {
  result = Value::named("unittest.TestCase").(ClassValue).lookup("assertRaises")
}

// Checks if an expression is in a test for exception raising
predicate inRaisesTest(Expr expr) {
  exists(With withBlock |
    withBlock.contains(expr) and
    withBlock.getContextExpr() = assertRaisesMethod().getACall().getNode()
  )
}

// Checks if an expression is a Python 2 print statement
predicate python2Print(Expr expr) {
  expr.(BinaryExpr).getLeft().(Name).getId() = "print" and
  expr.(BinaryExpr).getOp() instanceof RShift
  or
  python2Print(expr.(Tuple).getElt(0))
}

// Determines if an expression has no effect
predicate noEffect(Expr expr) {
  // Strings can be used as docstrings/comments
  not expr instanceof StringLiteral and
  not expr.hasSideEffects() and
  // Check all sub-expressions for side effects
  forall(Expr subExpr | subExpr = expr.getASubExpression*() |
    not sideEffectingBinary(subExpr) and
    not maybeSideEffectingAttribute(subExpr)
  ) and
  // Exclude special contexts where expressions are expected
  not inNotebook(expr) and
  not inRaisesTest(expr) and
  not python2Print(expr)
}

// Main query to find statements with no effect
from ExprStmt stmt
where noEffect(stmt.getValue())
select stmt, "This statement has no effect."