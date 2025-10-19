/**
 * @name Conflicting attributes in base classes
 * @description Finds classes inheriting from multiple base classes that define the same attribute,
 *              potentially causing unexpected behavior due to attribute overriding conflicts.
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
  not exists(Stmt stmt | stmt.getScope() = functionObj.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = functionObj.getFunction().getDocString()
  )
}

/**
 * Checks if a function contains a super() call for its own name.
 * This indicates the method properly handles inheritance by calling
 * the parent class's implementation.
 */
predicate has_super_call(FunctionObject methodObj) {
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = methodObj.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = methodObj.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * Specifies attribute names that are exempt from conflict detection.
 * Currently only includes 'process_request' due to special handling
 * in Python's socketserver module (per documentation).
 */
predicate is_exempt_attribute(string attrName) {
  attrName = "process_request"  // Recommended in Python docs for async mixins
}

from
  ClassObject derivedClass, 
  ClassObject baseClass1, 
  ClassObject baseClass2, 
  string attributeName, 
  int baseIndex1, 
  int baseIndex2, 
  Object attributeInBase1, 
  Object attributeInBase2
where
  // Establish inheritance relationships with distinct base classes
  (
    derivedClass.getBaseType(baseIndex1) = baseClass1 and
    derivedClass.getBaseType(baseIndex2) = baseClass2 and
    baseIndex1 < baseIndex2
  ) and
  
  // Locate conflicting attributes in different base classes
  (
    attributeInBase1 = baseClass1.lookupAttribute(attributeName) and
    attributeInBase2 = baseClass2.lookupAttribute(attributeName) and
    attributeInBase1 != attributeInBase2
  ) and
  
  // Filter out special method names and exempt attributes
  (
    not attributeName.matches("\\_\\_%\\_\\_") and
    not is_exempt_attribute(attributeName)
  ) and
  
  // Exclude cases where inheritance is properly handled
  (
    not has_super_call(attributeInBase1) and
    not is_empty_function(attributeInBase2) and
    not attributeInBase1.overrides(attributeInBase2) and
    not attributeInBase2.overrides(attributeInBase1)
  ) and
  
  // Ensure the derived class doesn't resolve the conflict
  not derivedClass.declaresAttribute(attributeName)
select 
  derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attributeInBase1, attributeInBase1.toString(), 
  attributeInBase2, attributeInBase2.toString()