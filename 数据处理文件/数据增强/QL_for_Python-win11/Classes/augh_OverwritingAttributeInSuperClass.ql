/**
 * @name Overwriting attribute in super-class or sub-class
 * @description Detects assignments to self attributes that overwrite attributes defined in subclass or superclass `__init__` methods.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       modularity
 * @problem.severity warning
 * @sub-severity low
 * @precision medium
 * @id py/overwritten-inherited-attribute
 */

import python

// Represents statements that call the __init__ method
class InitCallStmt extends ExprStmt {
  InitCallStmt() {
    exists(Call initCall, Attribute initAttr | 
      initCall = this.getValue() and 
      initAttr = initCall.getFunc() |
      initAttr.getName() = "__init__"
    )
  }
}

// Determines if an assignment overwrites superclass/subclass attributes based on position relative to __init__ call
predicate determines_overwrite_type(Function subInit, AssignStmt attributeAssignment, string overwriteType) {
  attributeAssignment.getScope() = subInit and
  self_attribute_write(attributeAssignment, _) and
  exists(Stmt containerStmt | containerStmt.contains(attributeAssignment) or containerStmt = attributeAssignment |
    (
      // Assignment after __init__ call indicates superclass attribute overwrite
      exists(int assignIdx, int initIdx, InitCallStmt initCall | 
        initCall.getScope() = subInit |
        assignIdx > initIdx and 
        containerStmt = subInit.getStmt(assignIdx) and 
        initCall = subInit.getStmt(initIdx) and 
        overwriteType = "superclass"
      )
      or
      // Assignment before __init__ call indicates subclass attribute overwrite
      exists(int assignIdx, int initIdx, InitCallStmt initCall | 
        initCall.getScope() = subInit |
        assignIdx < initIdx and 
        containerStmt = subInit.getStmt(assignIdx) and 
        initCall = subInit.getStmt(initIdx) and 
        overwriteType = "subclass"
      )
    )
  )
}

// Identifies statements that assign to self attributes
predicate self_attribute_write(Stmt stmt, string attributeName) {
  exists(Attribute attr, Name selfRef |
    selfRef = attr.getObject() and
    stmt.contains(attr) and
    selfRef.getId() = "self" and
    attr.getCtx() instanceof Store and
    attr.getName() = attributeName
  )
}

// Checks if two functions assign to the same attribute
predicate same_attribute_assigned(Stmt stmt1, Stmt stmt2, Function func1, Function func2) {
  exists(string attrName |
    stmt1.getScope() = func1 and
    stmt2.getScope() = func2 and
    self_attribute_write(stmt1, attrName) and
    self_attribute_write(stmt2, attrName)
  )
}

// Detects attribute overwriting scenarios with detailed context
predicate detects_attribute_overwrite(
  AssignStmt overwritingAssignment, AssignStmt overwrittenAssignment, 
  string attributeName, string overwrittenType, string className
) {
  exists(
    FunctionObject superInit, FunctionObject subInit, 
    ClassObject superClass, ClassObject subClass,
    AssignStmt subClassAssign, AssignStmt superClassAssign
  |
    (
      // Superclass attribute overwrite scenario
      overwrittenType = "superclass" and
      className = superClass.getName() and
      overwritingAssignment = subClassAssign and
      overwrittenAssignment = superClassAssign
      or
      // Subclass attribute overwrite scenario
      overwrittenType = "subclass" and
      className = subClass.getName() and
      overwritingAssignment = superClassAssign and
      overwrittenAssignment = subClassAssign
    ) and
    // Valid only if not a class attribute or is subclass overwrite
    (not exists(superClass.declaredAttribute(attributeName)) or overwrittenType = "subclass") and
    // Ensure both classes have __init__ methods
    superClass.declaredAttribute("__init__") = superInit and
    subClass.declaredAttribute("__init__") = subInit and
    // Verify inheritance relationship
    superClass = subClass.getASuperType() and
    // Validate overwrite position logic
    determines_overwrite_type(subInit.getFunction(), subClassAssign, overwrittenType) and
    // Confirm same attribute assignment
    same_attribute_assigned(subClassAssign, superClassAssign, subInit.getFunction(), superInit.getFunction()) and
    // Verify overwritten assignment is to self attribute
    self_attribute_write(superClassAssign, attributeName)
  )
}

// Query to identify and report attribute overwriting cases
from string overwrittenType, AssignStmt overwritingAssignment, AssignStmt overwrittenAssignment, string attributeName, string className
where detects_attribute_overwrite(overwritingAssignment, overwrittenAssignment, attributeName, overwrittenType, className)
select overwritingAssignment,
  "Assignment overwrites attribute " + attributeName + ", which was previously defined in " + overwrittenType +
    " $@.", overwrittenAssignment, className