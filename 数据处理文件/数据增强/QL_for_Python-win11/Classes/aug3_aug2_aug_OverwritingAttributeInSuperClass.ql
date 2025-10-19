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
    exists(Call initCallExpr, Attribute initAttrExpr | 
      initCallExpr = this.getValue() and 
      initAttrExpr = initCallExpr.getFunc() and
      initAttrExpr.getName() = "__init__"
    )
  }
}

// Identifies statements assigning to self attributes
predicate assignsToSelfAttribute(Stmt assignmentStmt, string attributeName) {
  exists(Attribute selfAttrExpr, Name selfVarExpr |
    selfVarExpr = selfAttrExpr.getObject() and
    assignmentStmt.contains(selfAttrExpr) and
    selfVarExpr.getId() = "self" and
    selfAttrExpr.getCtx() instanceof Store and
    selfAttrExpr.getName() = attributeName
  )
}

// Determines assignment position relative to __init__ calls
predicate isAssignmentRelativeToInitCall(
  Function initFunction, 
  AssignStmt attributeAssignment, 
  string relativePosition
) {
  attributeAssignment.getScope() = initFunction and
  assignsToSelfAttribute(attributeAssignment, _) and
  exists(Stmt container | 
    container.contains(attributeAssignment) or container = attributeAssignment
  |
    (
      // Assignment after superclass __init__ call
      exists(int assignPosition, int initPosition, InitCallStmt initCallExpr | 
        initCallExpr.getScope() = initFunction and
        assignPosition > initPosition and
        container = initFunction.getStmt(assignPosition) and
        initCallExpr = initFunction.getStmt(initPosition) and
        relativePosition = "superclass"
      )
      or
      // Assignment before subclass __init__ call
      exists(int assignPosition, int initPosition, InitCallStmt initCallExpr | 
        initCallExpr.getScope() = initFunction and
        assignPosition < initPosition and
        container = initFunction.getStmt(assignPosition) and
        initCallExpr = initFunction.getStmt(initPosition) and
        relativePosition = "subclass"
      )
    )
  )
}

// Checks if two functions assign to the same attribute
predicate assignsSameAttribute(
  Stmt assignment1, 
  Stmt assignment2, 
  Function function1, 
  Function function2
) {
  exists(string commonAttribute |
    assignment1.getScope() = function1 and
    assignment2.getScope() = function2 and
    assignsToSelfAttribute(assignment1, commonAttribute) and
    assignsToSelfAttribute(assignment2, commonAttribute)
  )
}

// Detects attribute overwriting in inheritance hierarchy
predicate isInheritanceAttributeOverwrite(
  AssignStmt overwritingAssignment, 
  AssignStmt overwrittenAssignment, 
  string attributeName, 
  string inheritanceRelation, 
  string sourceClassName
) {
  exists(
    FunctionObject superInit, 
    FunctionObject subInit, 
    ClassObject superClass, 
    ClassObject subClass,
    AssignStmt subClassAssignment,
    AssignStmt superClassAssignment
  |
    // Set assignment relationships based on inheritance type
    (
      inheritanceRelation = "superclass" and
      sourceClassName = superClass.getName() and
      overwritingAssignment = subClassAssignment and
      overwrittenAssignment = superClassAssignment
      or
      inheritanceRelation = "subclass" and
      sourceClassName = subClass.getName() and
      overwritingAssignment = superClassAssignment and
      overwrittenAssignment = subClassAssignment
    ) and
    // Exclude class attributes unless overwritten in subclass
    (not exists(superClass.declaredAttribute(attributeName)) or inheritanceRelation = "subclass") and
    // Verify both classes have __init__ methods
    superClass.declaredAttribute("__init__") = superInit and
    subClass.declaredAttribute("__init__") = subInit and
    // Ensure inheritance relationship
    superClass = subClass.getASuperType() and
    // Check assignment position relative to __init__ calls
    isAssignmentRelativeToInitCall(subInit.getFunction(), subClassAssignment, inheritanceRelation) and
    // Confirm same attribute is assigned in both functions
    assignsSameAttribute(
      subClassAssignment, 
      superClassAssignment, 
      subInit.getFunction(), 
      superInit.getFunction()
    ) and
    // Verify overwritten assignment targets self attribute
    assignsToSelfAttribute(superClassAssignment, attributeName)
  )
}

// Query results: Identify attribute overwrites with contextual information
from string inheritanceRelation, AssignStmt overwritingAssignment, AssignStmt overwrittenAssignment, string attributeName, string sourceClassName
where isInheritanceAttributeOverwrite(overwritingAssignment, overwrittenAssignment, attributeName, inheritanceRelation, sourceClassName)
select overwritingAssignment,
  "Assignment overwrites attribute " + attributeName + ", which was previously defined in " + inheritanceRelation +
    " $@.", overwrittenAssignment, sourceClassName