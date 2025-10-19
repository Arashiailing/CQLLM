/**
 * @name Overwriting attribute in super-class or sub-class
 * @description Detects assignments to instance attributes that overwrite attributes 
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

// Represents statements that call the __init__ method
class InitMethodCallStmt extends ExprStmt {
  InitMethodCallStmt() {
    exists(Call initCall, Attribute initAttr | 
      initCall = this.getValue() and 
      initAttr = initCall.getFunc() and
      initAttr.getName() = "__init__"
    )
  }
}

// Identifies statements that assign to instance attributes (self.attr = value)
predicate assignsToInstanceAttribute(Stmt stmt, string attributeName) {
  exists(Attribute instanceAttr, Name selfVar |
    selfVar = instanceAttr.getObject() and
    stmt.contains(instanceAttr) and
    selfVar.getId() = "self" and
    instanceAttr.getCtx() instanceof Store and
    instanceAttr.getName() = attributeName
  )
}

// Determines the position of an attribute assignment relative to __init__ method calls
predicate hasAssignmentRelativeToInitCall(
  Function initMethod, 
  AssignStmt attributeAssignment, 
  string relationType
) {
  attributeAssignment.getScope() = initMethod and
  assignsToInstanceAttribute(attributeAssignment, _) and
  exists(Stmt container | 
    container.contains(attributeAssignment) or container = attributeAssignment
  |
    (
      // Assignment occurs after superclass __init__ call
      relationType = "superclass" and
      exists(int assignmentPosition, int initCallPosition, InitMethodCallStmt initCall | 
        initCall.getScope() = initMethod and
        assignmentPosition > initCallPosition and
        container = initMethod.getStmt(assignmentPosition) and
        initCall = initMethod.getStmt(initCallPosition)
      )
      or
      // Assignment occurs before subclass __init__ call
      relationType = "subclass" and
      exists(int assignmentPosition, int initCallPosition, InitMethodCallStmt initCall | 
        initCall.getScope() = initMethod and
        assignmentPosition < initCallPosition and
        container = initMethod.getStmt(assignmentPosition) and
        initCall = initMethod.getStmt(initCallPosition)
      )
    )
  )
}

// Checks if two different functions assign to the same attribute name
predicate assignsToSameAttribute(
  Stmt firstStmt, 
  Stmt secondStmt, 
  Function firstFunction, 
  Function secondFunction
) {
  exists(string commonAttributeName |
    firstStmt.getScope() = firstFunction and
    secondStmt.getScope() = secondFunction and
    assignsToInstanceAttribute(firstStmt, commonAttributeName) and
    assignsToInstanceAttribute(secondStmt, commonAttributeName)
  )
}

// Detects when an attribute assignment in one class overwrites an attribute assignment in another class
predicate hasInheritanceAttributeOverwrite(
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
    
    // Exclude class attributes unless they are overwritten in a subclass
    (not exists(superClass.declaredAttribute(attributeName)) or inheritanceType = "subclass") and
    
    // Check the position of the assignment relative to __init__ calls
    hasAssignmentRelativeToInitCall(subInitMethod.getFunction(), subclassAttributeAssignment, inheritanceType) and
    
    // Confirm that the same attribute is assigned in both functions
    assignsToSameAttribute(
      subclassAttributeAssignment, 
      superclassAttributeAssignment, 
      subInitMethod.getFunction(), 
      superInitMethod.getFunction()
    ) and
    
    // Verify that the overwritten assignment targets an instance attribute
    assignsToInstanceAttribute(superclassAttributeAssignment, attributeName)
  )
}

// Query results: Identify attribute overwrites with contextual information
from string inheritanceType, AssignStmt overwritingAssignment, AssignStmt overwrittenAssignment, string attributeName, string className
where hasInheritanceAttributeOverwrite(overwritingAssignment, overwrittenAssignment, attributeName, inheritanceType, className)
select overwritingAssignment,
  "Assignment overwrites attribute " + attributeName + ", which was previously defined in " + inheritanceType +
    " $@.", overwrittenAssignment, className