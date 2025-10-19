/**
 * @name Conflicting attributes in base classes
 * @description Detects inheritance scenarios where multiple base classes define the same attribute
 *              with different implementations, potentially causing runtime conflicts due to
 *              the method resolution order (MRO).
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
 * Determines if a function implementation is effectively empty, containing only
 * pass statements and/or docstrings without any operational logic.
 */
predicate is_empty_function(PyFunctionObject functionObj) {
  not exists(Stmt stmt | stmt.getScope() = functionObj.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = functionObj.getFunction().getDocString()
  )
}

/**
 * Identifies when a method intentionally delegates to its parent implementation
 * using super(), indicating safe overriding behavior.
 */
predicate has_super_call(FunctionObject functionObj) {
  exists(Call superInvocation, Call methodInvocation, Attribute attribute, GlobalVariable superGlobalVar |
    methodInvocation.getScope() = functionObj.getFunction() and
    methodInvocation.getFunc() = attribute and
    attribute.getObject() = superInvocation and
    attribute.getName() = functionObj.getName() and
    superInvocation.getFunc() = superGlobalVar.getAnAccess() and
    superGlobalVar.getId() = "super"
  )
}

/**
 * Defines attribute names that should be excluded from conflict detection
 * based on standard library recommendations or special cases.
 */
predicate is_exempt_attribute(string attributeName) {
  /*
   * Exemption based on standard library recommendation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attributeName = "process_request"
}

from
  ClassObject childClass, ClassObject baseClass1, ClassObject baseClass2, 
  string conflictingAttr, int baseIndex1, int baseIndex2, 
  Object attrInBase1, Object attrInBase2
where
  // Establish inheritance hierarchy with ordered base classes
  childClass.getBaseType(baseIndex1) = baseClass1 and
  childClass.getBaseType(baseIndex2) = baseClass2 and
  baseIndex1 < baseIndex2 and
  
  // Identify attribute conflict between base classes
  attrInBase1 = baseClass1.lookupAttribute(conflictingAttr) and
  attrInBase2 = baseClass2.lookupAttribute(conflictingAttr) and
  attrInBase1 != attrInBase2 and
  
  // Apply conflict filtering conditions
  (
    // Exclude Python special methods (dunder methods)
    not conflictingAttr.matches("\\_\\_%\\_\\_") and
    
    // Exclude methods with intentional super() delegation
    not has_super_call(attrInBase1) and
    
    // Ignore empty implementations in second base class
    not is_empty_function(attrInBase2) and
    
    // Skip exempted attribute names
    not is_exempt_attribute(conflictingAttr) and
    
    // Ensure no override relationship exists between attributes
    not attrInBase1.overrides(attrInBase2) and
    not attrInBase2.overrides(attrInBase1) and
    
    // Verify child class doesn't explicitly declare the attribute
    not childClass.declaresAttribute(conflictingAttr)
  )
select childClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttr + "': $@ and $@.", 
  attrInBase1, attrInBase1.toString(), 
  attrInBase2, attrInBase2.toString()