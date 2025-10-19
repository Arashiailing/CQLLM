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

// Checks if an assignment overwrites an attribute from inheritance hierarchy
predicate inheritance_attribute_overwrite(
  AssignStmt overwritingAssign, 
  AssignStmt overwrittenAssign, 
  string attrName, 
  string inheritRelation, 
  string clsName
) {
  exists(
    FunctionObject baseClassInit, 
    FunctionObject derivedClassInit, 
    ClassObject baseClass, 
    ClassObject derivedClass,
    AssignStmt derivedAttrAssign,
    AssignStmt baseAttrAssign
  |
    // Establish inheritance relationship
    baseClass = derivedClass.getASuperType() and
    // Verify both classes have __init__ methods
    baseClass.declaredAttribute("__init__") = baseClassInit and
    derivedClass.declaredAttribute("__init__") = derivedClassInit and
    
    // Determine overwrite direction and assignments
    (
      // Superclass attribute being overwritten
      inheritRelation = "superclass" and
      clsName = baseClass.getName() and
      overwritingAssign = derivedAttrAssign and
      overwrittenAssign = baseAttrAssign
      or
      // Subclass attribute being overwritten
      inheritRelation = "subclass" and
      clsName = derivedClass.getName() and
      overwritingAssign = baseAttrAssign and
      overwrittenAssign = derivedAttrAssign
    ) and
    
    // Exclude class attributes unless overwritten in subclass
    (not exists(baseClass.declaredAttribute(attrName)) or inheritRelation = "subclass") and
    
    // Check assignment location relative to __init__ calls
    attribute_assignment_location(derivedClassInit.getFunction(), derivedAttrAssign, inheritRelation) and
    
    // Confirm same attribute is assigned in both functions
    matching_attribute_assignment(
      derivedAttrAssign, 
      baseAttrAssign, 
      derivedClassInit.getFunction(), 
      baseClassInit.getFunction()
    ) and
    
    // Verify overwritten assignment targets self attribute
    self_attribute_assignment(baseAttrAssign, attrName)
  )
}

// Identifies statements assigning to self attributes
predicate self_attribute_assignment(Stmt statement, string attrName) {
  exists(Attribute attr, Name selfName |
    selfName = attr.getObject() and
    statement.contains(attr) and
    selfName.getId() = "self" and
    attr.getCtx() instanceof Store and
    attr.getName() = attrName
  )
}

// Checks if two functions assign to the same attribute
predicate matching_attribute_assignment(
  Stmt stmtOne, 
  Stmt stmtTwo, 
  Function funcOne, 
  Function funcTwo
) {
  exists(string commonAttrName |
    stmtOne.getScope() = funcOne and
    stmtTwo.getScope() = funcTwo and
    self_attribute_assignment(stmtOne, commonAttrName) and
    self_attribute_assignment(stmtTwo, commonAttrName)
  )
}

// Determines assignment position relative to __init__ calls
predicate attribute_assignment_location(
  Function derivedClassInit, 
  AssignStmt attrAssignStmt, 
  string inheritRelation
) {
  attrAssignStmt.getScope() = derivedClassInit and
  self_attribute_assignment(attrAssignStmt, _) and
  exists(Stmt container | 
    container.contains(attrAssignStmt) or container = attrAssignStmt
  |
    (
      // Assignment occurs after superclass __init__ call
      exists(int assignIdx, int initIdx, InitCallStmt initCall | 
        initCall.getScope() = derivedClassInit and
        assignIdx > initIdx and
        container = derivedClassInit.getStmt(assignIdx) and
        initCall = derivedClassInit.getStmt(initIdx) and
        inheritRelation = "superclass"
      )
      or
      // Assignment occurs before subclass __init__ call
      exists(int assignIdx, int initIdx, InitCallStmt initCall | 
        initCall.getScope() = derivedClassInit and
        assignIdx < initIdx and
        container = derivedClassInit.getStmt(assignIdx) and
        initCall = derivedClassInit.getStmt(initIdx) and
        inheritRelation = "subclass"
      )
    )
  )
}

// Query results: Identify attribute overwrites with contextual information
from string inheritRelation, AssignStmt overwritingAssign, AssignStmt overwrittenAssign, string attrName, string clsName
where inheritance_attribute_overwrite(overwritingAssign, overwrittenAssign, attrName, inheritRelation, clsName)
select overwritingAssign,
  "Assignment overwrites attribute " + attrName + ", which was previously defined in " + inheritRelation +
    " $@.", overwrittenAssign, clsName