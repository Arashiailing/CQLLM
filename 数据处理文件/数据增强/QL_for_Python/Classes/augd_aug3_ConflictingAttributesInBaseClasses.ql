/**
 * @name Conflicting attributes in base classes
 * @description Detects when a class inherits multiple base classes defining the same attribute,
 *              which may cause unexpected behavior due to attribute overriding conflicts.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       modularity
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/conflicting-attributes
 */

import python

/**
 * Determines if a function implementation is effectively empty.
 * A function is considered empty if its body contains only pass statements
 * or its docstring expression.
 */
predicate is_empty_function(PyFunctionObject functionObj) {
  not exists(Stmt statement | statement.getScope() = functionObj.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = functionObj.getFunction().getDocString()
  )
}

/**
 * Checks if a function contains a super() call for its own name.
 * This indicates the method properly handles inheritance by calling
 * the parent class's implementation.
 */
predicate has_super_call(FunctionObject functionObj) {
  exists(Call superCallExpr, Call methodCallExpr, Attribute attributeExpr, GlobalVariable superGlobalVar |
    methodCallExpr.getScope() = functionObj.getFunction() and
    methodCallExpr.getFunc() = attributeExpr and
    attributeExpr.getObject() = superCallExpr and
    attributeExpr.getName() = functionObj.getName() and
    superCallExpr.getFunc() = superGlobalVar.getAnAccess() and
    superGlobalVar.getId() = "super"
  )
}

/**
 * Identifies attribute names that are exempt from conflict detection.
 * Currently only includes 'process_request' due to special handling
 * in Python's socketserver module (per documentation).
 */
predicate is_exempt_attribute(string attrName) {
  attrName = "process_request"  // Recommended in Python docs for async mixins
}

from
  ClassObject childClass, 
  ClassObject baseClassA, 
  ClassObject baseClassB, 
  string attrName, 
  int baseIndexA, 
  int baseIndexB, 
  Object attrInBaseA, 
  Object attrInBaseB
where
  // Establish distinct inheritance relationships
  childClass.getBaseType(baseIndexA) = baseClassA and
  childClass.getBaseType(baseIndexB) = baseClassB and
  baseIndexA < baseIndexB and
  
  // Locate conflicting attributes in different base classes
  attrInBaseA = baseClassA.lookupAttribute(attrName) and
  attrInBaseB = baseClassB.lookupAttribute(attrName) and
  attrInBaseA != attrInBaseB and
  
  // Filter special methods and exempt attributes
  not attrName.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(attrName) and
  
  // Exclude properly handled inheritance cases
  not has_super_call(attrInBaseA) and
  not is_empty_function(attrInBaseB) and
  not attrInBaseA.overrides(attrInBaseB) and
  not attrInBaseB.overrides(attrInBaseA) and
  
  // Ensure child class doesn't resolve the conflict
  not childClass.declaresAttribute(attrName)
select 
  childClass, 
  "Base classes have conflicting values for attribute '" + attrName + "': $@ and $@.", 
  attrInBaseA, attrInBaseA.toString(), 
  attrInBaseB, attrInBaseB.toString()