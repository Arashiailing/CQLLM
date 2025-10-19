/**
 * @name Overwriting attribute in super-class or sub-class
 * @description Detects assignments to self attributes that overwrite attributes previously defined in subclass or superclass `__init__` methods.
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

// Represents an expression statement that calls an __init__ method
class InitCallStmt extends ExprStmt {
  InitCallStmt() {
    exists(Call initCall, Attribute initAttr | 
      initCall = this.getValue() and 
      initAttr = initCall.getFunc() |
      initAttr.getName() = "__init__"
    )
  }
}

// Determines whether an assignment overwrites a superclass/subclass attribute
predicate identifies_overwritten_type(Function subInit, AssignStmt attrAssignment, string overwrittenType) {
  attrAssignment.getScope() = subInit and
  is_self_assignment(attrAssignment, _) and
  exists(Stmt container | container.contains(attrAssignment) or container = attrAssignment |
    (
      // Case 1: Overwrites superclass attribute (assignment after super().__init__())
      exists(int assignIdx, int initIdx, InitCallStmt superInitCall | 
        superInitCall.getScope() = subInit |
        assignIdx > initIdx and 
        container = subInit.getStmt(assignIdx) and 
        superInitCall = subInit.getStmt(initIdx) and 
        overwrittenType = "superclass"
      )
      or
      // Case 2: Overwrites subclass attribute (assignment before super().__init__())
      exists(int assignIdx, int initIdx, InitCallStmt superInitCall | 
        superInitCall.getScope() = subInit |
        assignIdx < initIdx and 
        container = subInit.getStmt(assignIdx) and 
        superInitCall = subInit.getStmt(initIdx) and 
        overwrittenType = "subclass"
      )
    )
  )
}

// Checks if a statement performs a self attribute assignment
predicate is_self_assignment(Stmt stmt, string attrName) {
  exists(Attribute attr, Name selfRef |
    selfRef = attr.getObject() and
    stmt.contains(attr) and
    selfRef.getId() = "self" and
    attr.getCtx() instanceof Store and
    attr.getName() = attrName
  )
}

// Verifies if two functions assign to the same attribute
predicate assign_same_attribute(Stmt stmt1, Stmt stmt2, Function func1, Function func2) {
  exists(string name |
    stmt1.getScope() = func1 and
    stmt2.getScope() = func2 and
    is_self_assignment(stmt1, name) and
    is_self_assignment(stmt2, name)
  )
}

// Identifies attribute overwriting scenarios
predicate find_attribute_overwrite(
  AssignStmt overwritingAssign, AssignStmt overwrittenAssign, string attrName, 
  string overwrittenType, string className
) {
  exists(
    FunctionObject superInitFunc, FunctionObject subInitFunc, 
    ClassObject superClass, ClassObject subClass,
    AssignStmt subClassAssign, AssignStmt superClassAssign
  |
    (
      // Superclass attribute overwrite case
      overwrittenType = "superclass" and
      className = superClass.getName() and
      overwritingAssign = subClassAssign and
      overwrittenAssign = superClassAssign
      or
      // Subclass attribute overwrite case
      overwrittenType = "subclass" and
      className = subClass.getName() and
      overwritingAssign = superClassAssign and
      overwrittenAssign = subClassAssign
    ) and
    // Skip if overwritten attribute is a class-level attribute in superclass
    (not exists(superClass.declaredAttribute(attrName)) or overwrittenType = "subclass") and
    // Verify both classes have __init__ methods
    superClass.declaredAttribute("__init__") = superInitFunc and
    subClass.declaredAttribute("__init__") = subInitFunc and
    // Verify inheritance relationship
    superClass = subClass.getASuperType() and
    // Confirm overwrite position relative to super().__init__ call
    identifies_overwritten_type(subInitFunc.getFunction(), subClassAssign, overwrittenType) and
    // Ensure both functions assign to the same attribute
    assign_same_attribute(subClassAssign, superClassAssign, subInitFunc.getFunction(), superInitFunc.getFunction()) and
    // Verify the overwritten assignment is a self attribute assignment
    is_self_assignment(superClassAssign, attrName)
  )
}

// Query to detect and report attribute overwrites
from string overwrittenType, AssignStmt overwritingAssign, AssignStmt overwrittenAssign, string attrName, string className
where find_attribute_overwrite(overwritingAssign, overwrittenAssign, attrName, overwrittenType, className)
select overwritingAssign,
  "Assignment overwrites attribute " + attrName + ", which was previously defined in " + overwrittenType +
    " $@.", overwrittenAssign, className