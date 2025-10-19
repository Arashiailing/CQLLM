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
    exists(Call initCall, Attribute initAttr | 
      initCall = this.getValue() and 
      initAttr = initCall.getFunc() and
      initAttr.getName() = "__init__"
    )
  }
}

// Identifies statements assigning to self attributes
predicate assignsToSelfAttribute(Stmt stmt, string attrName) {
  exists(Attribute selfAttr, Name selfVar |
    selfVar = selfAttr.getObject() and
    stmt.contains(selfAttr) and
    selfVar.getId() = "self" and
    selfAttr.getCtx() instanceof Store and
    selfAttr.getName() = attrName
  )
}

// Determines assignment position relative to __init__ calls
predicate isAssignmentRelativeToInitCall(
  Function initMethod, 
  AssignStmt attrAssign, 
  string relationType
) {
  attrAssign.getScope() = initMethod and
  assignsToSelfAttribute(attrAssign, _) and
  exists(Stmt container | 
    container.contains(attrAssign) or container = attrAssign
  |
    (
      // Assignment after superclass __init__ call
      exists(int assignPos, int initPos, InitCallStmt initCall | 
        initCall.getScope() = initMethod and
        assignPos > initPos and
        container = initMethod.getStmt(assignPos) and
        initCall = initMethod.getStmt(initPos) and
        relationType = "superclass"
      )
      or
      // Assignment before subclass __init__ call
      exists(int assignPos, int initPos, InitCallStmt initCall | 
        initCall.getScope() = initMethod and
        assignPos < initPos and
        container = initMethod.getStmt(assignPos) and
        initCall = initMethod.getStmt(initPos) and
        relationType = "subclass"
      )
    )
  )
}

// Checks if two functions assign to the same attribute
predicate assignsSameAttribute(
  Stmt stmt1, 
  Stmt stmt2, 
  Function func1, 
  Function func2
) {
  exists(string commonAttr |
    stmt1.getScope() = func1 and
    stmt2.getScope() = func2 and
    assignsToSelfAttribute(stmt1, commonAttr) and
    assignsToSelfAttribute(stmt2, commonAttr)
  )
}

// Detects attribute overwriting in inheritance hierarchy
predicate isInheritanceAttributeOverwrite(
  AssignStmt overwritingAssign, 
  AssignStmt overwrittenAssign, 
  string attrName, 
  string inheritanceType, 
  string className
) {
  exists(
    FunctionObject superInit, 
    FunctionObject subInit, 
    ClassObject superClass, 
    ClassObject subClass,
    AssignStmt subAttrAssign,
    AssignStmt superAttrAssign
  |
    // Set assignment relationships based on inheritance type
    (
      inheritanceType = "superclass" and
      className = superClass.getName() and
      overwritingAssign = subAttrAssign and
      overwrittenAssign = superAttrAssign
      or
      inheritanceType = "subclass" and
      className = subClass.getName() and
      overwritingAssign = superAttrAssign and
      overwrittenAssign = subAttrAssign
    ) and
    // Exclude class attributes unless overwritten in subclass
    (not exists(superClass.declaredAttribute(attrName)) or inheritanceType = "subclass") and
    // Verify both classes have __init__ methods
    superClass.declaredAttribute("__init__") = superInit and
    subClass.declaredAttribute("__init__") = subInit and
    // Ensure inheritance relationship
    superClass = subClass.getASuperType() and
    // Check assignment position relative to __init__ calls
    isAssignmentRelativeToInitCall(subInit.getFunction(), subAttrAssign, inheritanceType) and
    // Confirm same attribute is assigned in both functions
    assignsSameAttribute(
      subAttrAssign, 
      superAttrAssign, 
      subInit.getFunction(), 
      superInit.getFunction()
    ) and
    // Verify overwritten assignment targets self attribute
    assignsToSelfAttribute(superAttrAssign, attrName)
  )
}

// Query results: Identify attribute overwrites with contextual information
from string inheritanceType, AssignStmt overwritingAssign, AssignStmt overwrittenAssign, string attrName, string className
where isInheritanceAttributeOverwrite(overwritingAssign, overwrittenAssign, attrName, inheritanceType, className)
select overwritingAssign,
  "Assignment overwrites attribute " + attrName + ", which was previously defined in " + inheritanceType +
    " $@.", overwrittenAssign, className