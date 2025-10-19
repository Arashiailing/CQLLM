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
predicate assignsToSelfAttribute(Stmt assignStmt, string attrName) {
  exists(Attribute selfAttr, Name selfVar |
    selfVar = selfAttr.getObject() and
    assignStmt.contains(selfAttr) and
    selfVar.getId() = "self" and
    selfAttr.getCtx() instanceof Store and
    selfAttr.getName() = attrName
  )
}

// Determines assignment position relative to __init__ calls
predicate isAssignmentRelativeToInitCall(
  Function initFunc, 
  AssignStmt attrAssign, 
  string relPos
) {
  attrAssign.getScope() = initFunc and
  assignsToSelfAttribute(attrAssign, _) and
  exists(Stmt container | 
    container.contains(attrAssign) or container = attrAssign
  |
    (
      // Assignment after superclass __init__ call
      exists(int assignPos, int initPos, InitCallStmt initCall | 
        initCall.getScope() = initFunc and
        assignPos > initPos and
        container = initFunc.getStmt(assignPos) and
        initCall = initFunc.getStmt(initPos) and
        relPos = "superclass"
      )
      or
      // Assignment before subclass __init__ call
      exists(int assignPos, int initPos, InitCallStmt initCall | 
        initCall.getScope() = initFunc and
        assignPos < initPos and
        container = initFunc.getStmt(assignPos) and
        initCall = initFunc.getStmt(initPos) and
        relPos = "subclass"
      )
    )
  )
}

// Checks if two functions assign to the same attribute
predicate assignsSameAttribute(
  Stmt assign1, 
  Stmt assign2, 
  Function func1, 
  Function func2
) {
  exists(string commonAttr |
    assign1.getScope() = func1 and
    assign2.getScope() = func2 and
    assignsToSelfAttribute(assign1, commonAttr) and
    assignsToSelfAttribute(assign2, commonAttr)
  )
}

// Detects attribute overwriting in inheritance hierarchy
predicate isInheritanceAttributeOverwrite(
  AssignStmt overwritingAssign, 
  AssignStmt overwrittenAssign, 
  string attrName, 
  string inheritRel, 
  string sourceClsName
) {
  exists(
    FunctionObject superInitFunc, 
    FunctionObject subInitFunc, 
    ClassObject superCls, 
    ClassObject subCls,
    AssignStmt subClsAssign,
    AssignStmt superClsAssign
  |
    // Set assignment relationships based on inheritance type
    (
      inheritRel = "superclass" and
      sourceClsName = superCls.getName() and
      overwritingAssign = subClsAssign and
      overwrittenAssign = superClsAssign
      or
      inheritRel = "subclass" and
      sourceClsName = subCls.getName() and
      overwritingAssign = superClsAssign and
      overwrittenAssign = subClsAssign
    ) and
    // Exclude class attributes unless overwritten in subclass
    (not exists(superCls.declaredAttribute(attrName)) or inheritRel = "subclass") and
    // Verify both classes have __init__ methods
    superCls.declaredAttribute("__init__") = superInitFunc and
    subCls.declaredAttribute("__init__") = subInitFunc and
    // Ensure inheritance relationship
    superCls = subCls.getASuperType() and
    // Check assignment position relative to __init__ calls
    isAssignmentRelativeToInitCall(subInitFunc.getFunction(), subClsAssign, inheritRel) and
    // Confirm same attribute is assigned in both functions
    assignsSameAttribute(
      subClsAssign, 
      superClsAssign, 
      subInitFunc.getFunction(), 
      superInitFunc.getFunction()
    ) and
    // Verify overwritten assignment targets self attribute
    assignsToSelfAttribute(superClsAssign, attrName)
  )
}

// Query results: Identify attribute overwrites with contextual information
from string inheritRel, AssignStmt overwritingAssign, AssignStmt overwrittenAssign, string attrName, string sourceClsName
where isInheritanceAttributeOverwrite(overwritingAssign, overwrittenAssign, attrName, inheritRel, sourceClsName)
select overwritingAssign,
  "Assignment overwrites attribute " + attrName + ", which was previously defined in " + inheritRel +
    " $@.", overwrittenAssign, sourceClsName