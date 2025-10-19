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

// Represents statements calling the __init__ method
class InitCallStmt extends ExprStmt {
  InitCallStmt() {
    exists(Call call, Attribute attr | 
      call = this.getValue() and 
      attr = call.getFunc() and
      attr.getName() = "__init__"
    )
  }
}

// Determines if an assignment overwrites an attribute from superclass or subclass
predicate attribute_assignment_location(
  Function subclassInit, 
  AssignStmt attrAssignment, 
  string inheritanceType
) {
  attrAssignment.getScope() = subclassInit and
  self_attribute_assignment(attrAssignment, _) and
  exists(Stmt container | 
    container.contains(attrAssignment) or container = attrAssignment
  |
    (
      // Assignment occurs after superclass __init__ call
      exists(int assignIdx, int initIdx, InitCallStmt initCall | 
        initCall.getScope() = subclassInit and
        assignIdx > initIdx and
        container = subclassInit.getStmt(assignIdx) and
        initCall = subclassInit.getStmt(initIdx) and
        inheritanceType = "superclass"
      )
      or
      // Assignment occurs before subclass __init__ call
      exists(int assignIdx, int initIdx, InitCallStmt initCall | 
        initCall.getScope() = subclassInit and
        assignIdx < initIdx and
        container = subclassInit.getStmt(assignIdx) and
        initCall = subclassInit.getStmt(initIdx) and
        inheritanceType = "subclass"
      )
    )
  )
}

// Identifies statements assigning to self attributes
predicate self_attribute_assignment(Stmt stmt, string attributeName) {
  exists(Attribute attr, Name selfName |
    selfName = attr.getObject() and
    stmt.contains(attr) and
    selfName.getId() = "self" and
    attr.getCtx() instanceof Store and
    attr.getName() = attributeName
  )
}

// Checks if two functions assign to the same attribute
predicate matching_attribute_assignment(
  Stmt stmt1, 
  Stmt stmt2, 
  Function func1, 
  Function func2
) {
  exists(string attrName |
    stmt1.getScope() = func1 and
    stmt2.getScope() = func2 and
    self_attribute_assignment(stmt1, attrName) and
    self_attribute_assignment(stmt2, attrName)
  )
}

// Detects attribute overwriting between inheritance hierarchy
predicate inheritance_attribute_overwrite(
  AssignStmt overwritingAssignment, 
  AssignStmt overwrittenAssignment, 
  string attributeName, 
  string inheritanceType, 
  string className
) {
  exists(
    FunctionObject superclassInit, 
    FunctionObject subclassInit, 
    ClassObject superclass, 
    ClassObject subclass,
    AssignStmt subclassAttrAssignment,
    AssignStmt superclassAttrAssignment
  |
    (
      // Superclass attribute being overwritten
      inheritanceType = "superclass" and
      className = superclass.getName() and
      overwritingAssignment = subclassAttrAssignment and
      overwrittenAssignment = superclassAttrAssignment
      or
      // Subclass attribute being overwritten
      inheritanceType = "subclass" and
      className = subclass.getName() and
      overwritingAssignment = superclassAttrAssignment and
      overwrittenAssignment = subclassAttrAssignment
    ) and
    // Exclude class attributes unless overwritten in subclass
    (not exists(superclass.declaredAttribute(attributeName)) or inheritanceType = "subclass") and
    // Verify both classes have __init__ methods
    superclass.declaredAttribute("__init__") = superclassInit and
    subclass.declaredAttribute("__init__") = subclassInit and
    // Ensure inheritance relationship
    superclass = subclass.getASuperType() and
    // Check assignment location relative to __init__ calls
    attribute_assignment_location(subclassInit.getFunction(), subclassAttrAssignment, inheritanceType) and
    // Confirm same attribute is assigned in both functions
    matching_attribute_assignment(
      subclassAttrAssignment, 
      superclassAttrAssignment, 
      subclassInit.getFunction(), 
      superclassInit.getFunction()
    ) and
    // Verify overwritten assignment targets self attribute
    self_attribute_assignment(superclassAttrAssignment, attributeName)
  )
}

// Query results: Identify attribute overwrites with contextual information
from string inheritanceType, AssignStmt overwritingAssignment, AssignStmt overwrittenAssignment, string attributeName, string className
where inheritance_attribute_overwrite(overwritingAssignment, overwrittenAssignment, attributeName, inheritanceType, className)
select overwritingAssignment,
  "Assignment overwrites attribute " + attributeName + ", which was previously defined in " + inheritanceType +
    " $@.", overwrittenAssignment, className