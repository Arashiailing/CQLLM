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

/**
 * Represents statements that invoke the __init__ method.
 * Used to identify initialization calls within methods to determine
 * the relative order of attribute assignments.
 */
class InitCallStmt extends ExprStmt {
  InitCallStmt() {
    exists(Call initMethodCall, Attribute initMethodAttr | 
      initMethodCall = this.getValue() and 
      initMethodAttr = initMethodCall.getFunc() and
      initMethodAttr.getName() = "__init__"
    )
  }
}

/**
 * Identifies statements that assign values to self attributes.
 * @param statement The statement being checked for self attribute assignment.
 * @param attributeName The name of the attribute being assigned to self.
 */
predicate assignsToSelfAttribute(Stmt statement, string attributeName) {
  exists(Attribute selfAttr, Name selfVar |
    selfVar = selfAttr.getObject() and
    statement.contains(selfAttr) and
    selfVar.getId() = "self" and
    selfAttr.getCtx() instanceof Store and
    selfAttr.getName() = attributeName
  )
}

/**
 * Determines the position of an attribute assignment relative to __init__ calls.
 * @param initializerMethod The __init__ method containing the assignments.
 * @param attributeAssignment The attribute assignment statement being evaluated.
 * @param relationshipType The relationship type ("superclass" or "subclass").
 */
predicate isAssignmentRelativeToInitCall(
  Function initializerMethod, 
  AssignStmt attributeAssignment, 
  string relationshipType
) {
  attributeAssignment.getScope() = initializerMethod and
  assignsToSelfAttribute(attributeAssignment, _) and
  exists(Stmt container | 
    container.contains(attributeAssignment) or container = attributeAssignment
  |
    exists(int assignPos, int initPos, InitCallStmt initMethodCall | 
      initMethodCall.getScope() = initializerMethod and
      container = initializerMethod.getStmt(assignPos) and
      initMethodCall = initializerMethod.getStmt(initPos) and
      (
        // Case 1: Assignment occurs after superclass __init__ call
        relationshipType = "superclass" and assignPos > initPos
        or
        // Case 2: Assignment occurs before subclass __init__ call
        relationshipType = "subclass" and assignPos < initPos
      )
    )
  )
}

/**
 * Checks if two functions assign to the same attribute.
 * @param firstAssignment The first assignment statement.
 * @param secondAssignment The second assignment statement.
 * @param firstFunction The function containing the first assignment.
 * @param secondFunction The function containing the second assignment.
 */
predicate assignsSameAttribute(
  Stmt firstAssignment, 
  Stmt secondAssignment, 
  Function firstFunction, 
  Function secondFunction
) {
  exists(string commonAttributeName |
    firstAssignment.getScope() = firstFunction and
    secondAssignment.getScope() = secondFunction and
    assignsToSelfAttribute(firstAssignment, commonAttributeName) and
    assignsToSelfAttribute(secondAssignment, commonAttributeName)
  )
}

/**
 * Detects attribute overwriting in inheritance hierarchy.
 * @param overwritingAssignment The assignment that overwrites an attribute.
 * @param overwrittenAssignment The assignment that is being overwritten.
 * @param attributeName The name of the attribute being overwritten.
 * @param inheritanceType The type of inheritance relationship ("superclass" or "subclass").
 * @param classContainingOverwrite The name of the class where the overwriting occurs.
 */
predicate isInheritanceAttributeOverwrite(
  AssignStmt overwritingAssignment, 
  AssignStmt overwrittenAssignment, 
  string attributeName, 
  string inheritanceType, 
  string classContainingOverwrite
) {
  exists(
    FunctionObject superclassInitializer, 
    FunctionObject subclassInitializer, 
    ClassObject superclassType, 
    ClassObject subclassType,
    AssignStmt subclassAttributeAssignment,
    AssignStmt superclassAttributeAssignment
  |
    // Establish inheritance relationship and identify __init__ methods
    superclassType = subclassType.getASuperType() and
    superclassType.declaredAttribute("__init__") = superclassInitializer and
    subclassType.declaredAttribute("__init__") = subclassInitializer and
    
    // Determine assignment relationships based on inheritance type
    (
      inheritanceType = "superclass" and
      classContainingOverwrite = superclassType.getName() and
      overwritingAssignment = subclassAttributeAssignment and
      overwrittenAssignment = superclassAttributeAssignment
      or
      inheritanceType = "subclass" and
      classContainingOverwrite = subclassType.getName() and
      overwritingAssignment = superclassAttributeAssignment and
      overwrittenAssignment = subclassAttributeAssignment
    ) and
    
    // Exclude class attributes unless they are overwritten in subclass
    (not exists(superclassType.declaredAttribute(attributeName)) or inheritanceType = "subclass") and
    
    // Verify assignment position relative to __init__ calls
    isAssignmentRelativeToInitCall(subclassInitializer.getFunction(), subclassAttributeAssignment, inheritanceType) and
    
    // Confirm the same attribute is assigned in both functions
    assignsSameAttribute(
      subclassAttributeAssignment, 
      superclassAttributeAssignment, 
      subclassInitializer.getFunction(), 
      superclassInitializer.getFunction()
    ) and
    
    // Ensure the overwritten assignment targets a self attribute
    assignsToSelfAttribute(superclassAttributeAssignment, attributeName)
  )
}

// Main query: Identify attribute overwrites with contextual information
from string inheritanceType, AssignStmt overwritingAssignment, AssignStmt overwrittenAssignment, string attributeName, string classContainingOverwrite
where isInheritanceAttributeOverwrite(overwritingAssignment, overwrittenAssignment, attributeName, inheritanceType, classContainingOverwrite)
select overwritingAssignment,
  "Assignment overwrites attribute " + attributeName + ", which was previously defined in " + inheritanceType +
    " $@.", overwrittenAssignment, classContainingOverwrite