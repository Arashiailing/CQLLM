/**
 * @name Conflicting attributes in base classes
 * @description This query identifies classes that inherit from multiple base classes which define
 *              the same attribute with different implementations. Such conflicts can lead to 
 *              unexpected behavior due to the method resolution order in Python's inheritance model.
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
predicate is_empty_function(PyFunctionObject func) {
  not exists(Stmt stmt | stmt.getScope() = func.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/**
 * Checks if a function contains a super() call for its own name.
 * This indicates the method properly handles inheritance by calling
 * the parent class's implementation.
 */
predicate has_super_call(FunctionObject func) {
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = func.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = func.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * Identifies attribute names that are exempt from conflict detection.
 * Currently only includes 'process_request' due to special handling
 * in Python's socketserver module (per documentation).
 */
predicate is_exempt_attribute(string attributeName) {
  attributeName = "process_request"  // Recommended in Python docs for async mixins
}

from
  ClassObject childClass, 
  ClassObject baseClassA, 
  ClassObject baseClassB, 
  string attributeName, 
  int baseIndexA, 
  int baseIndexB, 
  Object attributeInBaseA, 
  Object attributeInBaseB
where
  // Establish inheritance relationships with distinct base classes
  childClass.getBaseType(baseIndexA) = baseClassA and
  childClass.getBaseType(baseIndexB) = baseClassB and
  baseIndexA < baseIndexB and
  
  // Locate conflicting attributes in different base classes
  attributeInBaseA = baseClassA.lookupAttribute(attributeName) and
  attributeInBaseB = baseClassB.lookupAttribute(attributeName) and
  attributeInBaseA != attributeInBaseB and
  
  // Filter out special method names and exempt attributes
  not attributeName.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(attributeName) and
  
  // Exclude cases where inheritance is properly handled
  not has_super_call(attributeInBaseA) and
  not is_empty_function(attributeInBaseB) and
  not attributeInBaseA.overrides(attributeInBaseB) and
  not attributeInBaseB.overrides(attributeInBaseA) and
  
  // Ensure the derived class doesn't resolve the conflict
  not childClass.declaresAttribute(attributeName)
select 
  childClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attributeInBaseA, attributeInBaseA.toString(), 
  attributeInBaseB, attributeInBaseB.toString()