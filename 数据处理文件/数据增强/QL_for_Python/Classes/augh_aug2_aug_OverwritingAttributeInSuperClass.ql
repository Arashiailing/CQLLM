/**
 * @name Overwriting attribute in super-class or sub-class
 * @description Identifies assignments to instance attributes that overwrite attributes 
 *              previously defined in subclass or superclass initializers.
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

// Represents statements that invoke the __init__ method
class InitializerCallStatement extends ExprStmt {
  InitializerCallStatement() {
    exists(Call initializerCall, Attribute initializerAttribute | 
      initializerCall = this.getValue() and 
      initializerAttribute = initializerCall.getFunc() and
      initializerAttribute.getName() = "__init__"
    )
  }
}

// Detects statements that assign values to instance attributes via self
predicate assignsToInstanceAttribute(Stmt statement, string attributeName) {
  exists(Attribute instanceAttribute, Name selfVariable |
    selfVariable = instanceAttribute.getObject() and
    statement.contains(instanceAttribute) and
    selfVariable.getId() = "self" and
    instanceAttribute.getCtx() instanceof Store and
    instanceAttribute.getName() = attributeName
  )
}

// Determines the temporal relationship between attribute assignments and initializer calls
predicate hasAssignmentRelativeToInitializerCall(
  Function initializerMethod, 
  AssignStmt attributeAssignment, 
  string relationshipType
) {
  attributeAssignment.getScope() = initializerMethod and
  assignsToInstanceAttribute(attributeAssignment, _) and
  exists(Stmt container | 
    container.contains(attributeAssignment) or container = attributeAssignment
  |
    (
      // Case 1: Assignment occurs after superclass __init__ invocation
      exists(int assignmentPosition, int initializerPosition, InitializerCallStatement initializerCall | 
        initializerCall.getScope() = initializerMethod and
        assignmentPosition > initializerPosition and
        container = initializerMethod.getStmt(assignmentPosition) and
        initializerCall = initializerMethod.getStmt(initializerPosition) and
        relationshipType = "superclass"
      )
      or
      // Case 2: Assignment occurs before subclass __init__ invocation
      exists(int assignmentPosition, int initializerPosition, InitializerCallStatement initializerCall | 
        initializerCall.getScope() = initializerMethod and
        assignmentPosition < initializerPosition and
        container = initializerMethod.getStmt(assignmentPosition) and
        initializerCall = initializerMethod.getStmt(initializerPosition) and
        relationshipType = "subclass"
      )
    )
  )
}

// Verifies if two functions assign to the same attribute name
predicate assignToCommonAttribute(
  Stmt firstStatement, 
  Stmt secondStatement, 
  Function firstFunction, 
  Function secondFunction
) {
  exists(string sharedAttributeName |
    firstStatement.getScope() = firstFunction and
    secondStatement.getScope() = secondFunction and
    assignsToInstanceAttribute(firstStatement, sharedAttributeName) and
    assignsToInstanceAttribute(secondStatement, sharedAttributeName)
  )
}

// Identifies instances where attributes are overwritten in inheritance hierarchies
predicate isInheritanceAttributeOverwrite(
  AssignStmt overwritingAssignment, 
  AssignStmt overwrittenAssignment, 
  string attributeName, 
  string inheritanceRelationship, 
  string qualifiedClassName
) {
  exists(
    FunctionObject superclassInitializer, 
    FunctionObject subclassInitializer, 
    ClassObject superclass, 
    ClassObject subclass,
    AssignStmt subclassAttributeAssignment,
    AssignStmt superclassAttributeAssignment
  |
    // Establish assignment relationships based on inheritance direction
    (
      inheritanceRelationship = "superclass" and
      qualifiedClassName = superclass.getName() and
      overwritingAssignment = subclassAttributeAssignment and
      overwrittenAssignment = superclassAttributeAssignment
      or
      inheritanceRelationship = "subclass" and
      qualifiedClassName = subclass.getName() and
      overwritingAssignment = superclassAttributeAssignment and
      overwrittenAssignment = subclassAttributeAssignment
    ) and
    // Exclude class attributes unless they are explicitly overwritten in subclass
    (not exists(superclass.declaredAttribute(attributeName)) or inheritanceRelationship = "subclass") and
    // Confirm both classes have initializer methods
    superclass.declaredAttribute("__init__") = superclassInitializer and
    subclass.declaredAttribute("__init__") = subclassInitializer and
    // Validate inheritance relationship
    superclass = subclass.getASuperType() and
    // Check temporal relationship between assignment and initializer calls
    hasAssignmentRelativeToInitializerCall(subclassInitializer.getFunction(), subclassAttributeAssignment, inheritanceRelationship) and
    // Verify both assignments target the same attribute
    assignToCommonAttribute(
      subclassAttributeAssignment, 
      superclassAttributeAssignment, 
      subclassInitializer.getFunction(), 
      superclassInitializer.getFunction()
    ) and
    // Ensure the overwritten assignment targets an instance attribute
    assignsToInstanceAttribute(superclassAttributeAssignment, attributeName)
  )
}

// Query results: Report attribute overwrites with contextual information
from string inheritanceRelationship, AssignStmt overwritingAssignment, AssignStmt overwrittenAssignment, string attributeName, string qualifiedClassName
where isInheritanceAttributeOverwrite(overwritingAssignment, overwrittenAssignment, attributeName, inheritanceRelationship, qualifiedClassName)
select overwritingAssignment,
  "Assignment overwrites attribute " + attributeName + ", which was previously defined in " + inheritanceRelationship +
    " $@.", overwrittenAssignment, qualifiedClassName