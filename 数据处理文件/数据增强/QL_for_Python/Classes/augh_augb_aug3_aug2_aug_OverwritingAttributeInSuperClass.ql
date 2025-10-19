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

// Represents statements invoking the __init__ method
class InitMethodCall extends ExprStmt {
  InitMethodCall() {
    exists(Call initInvocation, Attribute initMethod | 
      initInvocation = this.getValue() and 
      initMethod = initInvocation.getFunc() and
      initMethod.getName() = "__init__"
    )
  }
}

// Identifies statements assigning to self attributes
predicate assignsToSelfAttr(Stmt assignment, string attributeName) {
  exists(Attribute selfAttr, Name selfVar |
    selfVar = selfAttr.getObject() and
    assignment.contains(selfAttr) and
    selfVar.getId() = "self" and
    selfAttr.getCtx() instanceof Store and
    selfAttr.getName() = attributeName
  )
}

// Determines assignment position relative to __init__ calls
predicate hasAssignmentRelativeToInitCall(
  Function initMethod, 
  AssignStmt attrAssignment, 
  string relativePosition
) {
  attrAssignment.getScope() = initMethod and
  assignsToSelfAttr(attrAssignment, _) and
  exists(Stmt enclosingBlock | 
    enclosingBlock.contains(attrAssignment) or enclosingBlock = attrAssignment
  |
    (
      // Assignment after superclass __init__ call
      exists(int assignmentIndex, int initCallIndex, InitMethodCall superInitCall | 
        superInitCall.getScope() = initMethod and
        assignmentIndex > initCallIndex and
        enclosingBlock = initMethod.getStmt(assignmentIndex) and
        superInitCall = initMethod.getStmt(initCallIndex) and
        relativePosition = "superclass"
      )
      or
      // Assignment before subclass __init__ call
      exists(int assignmentIndex, int initCallIndex, InitMethodCall subInitCall | 
        subInitCall.getScope() = initMethod and
        assignmentIndex < initCallIndex and
        enclosingBlock = initMethod.getStmt(assignmentIndex) and
        subInitCall = initMethod.getStmt(initCallIndex) and
        relativePosition = "subclass"
      )
    )
  )
}

// Checks if two functions assign to the same attribute
predicate assignsSameAttr(
  Stmt assignment1, 
  Stmt assignment2, 
  Function method1, 
  Function method2
) {
  exists(string commonAttribute |
    assignment1.getScope() = method1 and
    assignment2.getScope() = method2 and
    assignsToSelfAttr(assignment1, commonAttribute) and
    assignsToSelfAttr(assignment2, commonAttribute)
  )
}

// Detects attribute overwriting in inheritance hierarchy
predicate isInheritedAttrOverwrite(
  AssignStmt overwritingAssignment, 
  AssignStmt overwrittenAssignment, 
  string attributeName, 
  string inheritanceRelation, 
  string sourceClassName
) {
  exists(
    FunctionObject superInitMethod, 
    FunctionObject subInitMethod, 
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
    superClass.declaredAttribute("__init__") = superInitMethod and
    subClass.declaredAttribute("__init__") = subInitMethod and
    // Ensure inheritance relationship
    superClass = subClass.getASuperType() and
    // Check assignment position relative to __init__ calls
    hasAssignmentRelativeToInitCall(subInitMethod.getFunction(), subClassAssignment, inheritanceRelation) and
    // Confirm same attribute is assigned in both functions
    assignsSameAttr(
      subClassAssignment, 
      superClassAssignment, 
      subInitMethod.getFunction(), 
      superInitMethod.getFunction()
    ) and
    // Verify overwritten assignment targets self attribute
    assignsToSelfAttr(superClassAssignment, attributeName)
  )
}

// Query results: Identify attribute overwrites with contextual information
from string inheritanceRelation, AssignStmt overwritingAssignment, AssignStmt overwrittenAssignment, string attributeName, string sourceClassName
where isInheritedAttrOverwrite(overwritingAssignment, overwrittenAssignment, attributeName, inheritanceRelation, sourceClassName)
select overwritingAssignment,
  "Assignment overwrites attribute " + attributeName + ", which was previously defined in " + inheritanceRelation +
    " $@.", overwrittenAssignment, sourceClassName