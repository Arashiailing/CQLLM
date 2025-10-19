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
predicate assignsToSelfAttribute(Stmt stmt, string attributeName) {
  exists(Attribute selfAttr, Name selfVar |
    selfVar = selfAttr.getObject() and
    stmt.contains(selfAttr) and
    selfVar.getId() = "self" and
    selfAttr.getCtx() instanceof Store and
    selfAttr.getName() = attributeName
  )
}

// Determines assignment position relative to __init__ calls
predicate isAssignmentRelativeToInitCall(
  Function initMethod, 
  AssignStmt attributeAssignment, 
  string relationType
) {
  attributeAssignment.getScope() = initMethod and
  assignsToSelfAttribute(attributeAssignment, _) and
  exists(Stmt container | 
    container.contains(attributeAssignment) or container = attributeAssignment
  |
    (
      // Assignment after superclass __init__ call
      relationType = "superclass" and
      exists(int assignmentPosition, int initCallPosition, InitCallStmt initCall | 
        initCall.getScope() = initMethod and
        assignmentPosition > initCallPosition and
        container = initMethod.getStmt(assignmentPosition) and
        initCall = initMethod.getStmt(initCallPosition)
      )
      or
      // Assignment before subclass __init__ call
      relationType = "subclass" and
      exists(int assignmentPosition, int initCallPosition, InitCallStmt initCall | 
        initCall.getScope() = initMethod and
        assignmentPosition < initCallPosition and
        container = initMethod.getStmt(assignmentPosition) and
        initCall = initMethod.getStmt(initCallPosition)
      )
    )
  )
}

// Checks if two functions assign to the same attribute
predicate assignsSameAttribute(
  Stmt firstStmt, 
  Stmt secondStmt, 
  Function firstFunction, 
  Function secondFunction
) {
  exists(string commonAttributeName |
    firstStmt.getScope() = firstFunction and
    secondStmt.getScope() = secondFunction and
    assignsToSelfAttribute(firstStmt, commonAttributeName) and
    assignsToSelfAttribute(secondStmt, commonAttributeName)
  )
}

// Detects attribute overwriting in inheritance hierarchy
predicate isInheritanceAttributeOverwrite(
  AssignStmt overwritingAssignment, 
  AssignStmt overwrittenAssignment, 
  string attributeName, 
  string inheritanceType, 
  string className
) {
  exists(
    FunctionObject superInitMethod, 
    FunctionObject subInitMethod, 
    ClassObject superClass, 
    ClassObject subClass,
    AssignStmt subclassAttributeAssignment,
    AssignStmt superclassAttributeAssignment
  |
    // Verify inheritance relationship and __init__ methods
    superClass = subClass.getASuperType() and
    superClass.declaredAttribute("__init__") = superInitMethod and
    subClass.declaredAttribute("__init__") = subInitMethod and
    
    // Set assignment relationships based on inheritance type
    (
      inheritanceType = "superclass" and
      className = superClass.getName() and
      overwritingAssignment = subclassAttributeAssignment and
      overwrittenAssignment = superclassAttributeAssignment
      or
      inheritanceType = "subclass" and
      className = subClass.getName() and
      overwritingAssignment = superclassAttributeAssignment and
      overwrittenAssignment = subclassAttributeAssignment
    ) and
    
    // Exclude class attributes unless overwritten in subclass
    (not exists(superClass.declaredAttribute(attributeName)) or inheritanceType = "subclass") and
    
    // Check assignment position relative to __init__ calls
    isAssignmentRelativeToInitCall(subInitMethod.getFunction(), subclassAttributeAssignment, inheritanceType) and
    
    // Confirm same attribute is assigned in both functions
    assignsSameAttribute(
      subclassAttributeAssignment, 
      superclassAttributeAssignment, 
      subInitMethod.getFunction(), 
      superInitMethod.getFunction()
    ) and
    
    // Verify overwritten assignment targets self attribute
    assignsToSelfAttribute(superclassAttributeAssignment, attributeName)
  )
}

// Query results: Identify attribute overwrites with contextual information
from string inheritanceType, AssignStmt overwritingAssignment, AssignStmt overwrittenAssignment, string attributeName, string className
where isInheritanceAttributeOverwrite(overwritingAssignment, overwrittenAssignment, attributeName, inheritanceType, className)
select overwritingAssignment,
  "Assignment overwrites attribute " + attributeName + ", which was previously defined in " + inheritanceType +
    " $@.", overwrittenAssignment, className