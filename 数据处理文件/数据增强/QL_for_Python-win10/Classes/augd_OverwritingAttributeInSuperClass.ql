/**
 * @name Overwriting attribute in super-class or sub-class
 * @description Detects assignments to self attributes that overwrite attributes 
 *              previously defined in subclass or superclass `__init__` methods.
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

// Represents expression statements that call __init__ methods
class InitCallStmt extends ExprStmt {
  InitCallStmt() {
    exists(Call methodCall, Attribute methodAttr | 
      methodCall = this.getValue() and 
      methodAttr = methodCall.getFunc() |
      methodAttr.getName() = "__init__"
    )
  }
}

// Determines if an assignment overwrites an attribute from superclass or subclass
predicate overwrites_which(Function subclassInit, AssignStmt assignment, string overwrittenType) {
  assignment.getScope() = subclassInit and
  self_write_stmt(assignment, _) and
  exists(Stmt container | container.contains(assignment) or container = assignment |
    (
      // Case 1: Overwrites superclass attribute (assignment after __init__ call)
      exists(int assignmentIdx, int initCallIdx, InitCallStmt initCall | 
        initCall.getScope() = subclassInit |
        assignmentIdx > initCallIdx and 
        container = subclassInit.getStmt(assignmentIdx) and 
        initCall = subclassInit.getStmt(initCallIdx) and 
        overwrittenType = "superclass"
      )
      or
      // Case 2: Overwrites subclass attribute (assignment before __init__ call)
      exists(int assignmentIdx, int initCallIdx, InitCallStmt initCall | 
        initCall.getScope() = subclassInit |
        assignmentIdx < initCallIdx and 
        container = subclassInit.getStmt(assignmentIdx) and 
        initCall = subclassInit.getStmt(initCallIdx) and 
        overwrittenType = "subclass"
      )
    )
  )
}

// Identifies statements that write to self attributes
predicate self_write_stmt(Stmt stmt, string attrName) {
  exists(Attribute attr, Name selfRef |
    selfRef = attr.getObject() and
    stmt.contains(attr) and
    selfRef.getId() = "self" and
    attr.getCtx() instanceof Store and
    attr.getName() = attrName
  )
}

// Checks if two functions assign to the same attribute
predicate both_assign_attribute(Stmt stmt1, Stmt stmt2, Function func1, Function func2) {
  exists(string commonAttr |
    stmt1.getScope() = func1 and
    stmt2.getScope() = func2 and
    self_write_stmt(stmt1, commonAttr) and
    self_write_stmt(stmt2, commonAttr)
  )
}

// Detects attribute overwriting scenarios
predicate attribute_overwritten(
  AssignStmt overwritingStmt, AssignStmt overwrittenStmt, string attrName, 
  string classType, string className
) {
  exists(
    FunctionObject superInit, FunctionObject subInit, 
    ClassObject superClass, ClassObject subClass,
    AssignStmt subAttrStmt, AssignStmt superAttrStmt
  |
    // Handle superclass/subclass overwriting cases
    (
      (classType = "superclass" and className = superClass.getName() and 
       overwritingStmt = subAttrStmt and overwrittenStmt = superAttrStmt)
      or
      (classType = "subclass" and className = subClass.getName() and 
       overwritingStmt = superAttrStmt and overwrittenStmt = subAttrStmt)
    ) and
    // Skip if superclass attribute is not declared or overwriting occurs in subclass
    (not exists(superClass.declaredAttribute(attrName)) or classType = "subclass") and
    // Ensure both classes have __init__ methods
    superClass.declaredAttribute("__init__") = superInit and
    subClass.declaredAttribute("__init__") = subInit and
    // Verify inheritance relationship
    superClass = subClass.getASuperType() and
    // Validate overwriting position relative to __init__ call
    overwrites_which(subInit.getFunction(), subAttrStmt, classType) and
    // Confirm same attribute assignment in both classes
    both_assign_attribute(subAttrStmt, superAttrStmt, subInit.getFunction(), superInit.getFunction()) and
    // Verify overwritten statement is a self attribute write
    self_write_stmt(superAttrStmt, attrName)
  )
}

// Query to find all attribute overwriting instances
from string classType, AssignStmt overwritingStmt, AssignStmt overwrittenStmt, string attrName, string className
where attribute_overwritten(overwritingStmt, overwrittenStmt, attrName, classType, className)
select overwritingStmt,
  "Assignment overwrites attribute " + attrName + ", which was previously defined in " + classType +
    " $@.", overwrittenStmt, className