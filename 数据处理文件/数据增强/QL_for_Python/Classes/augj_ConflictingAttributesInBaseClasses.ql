/**
 * @name Conflicting attributes in base classes
 * @description Detects when a class inherits from multiple base classes that define the same attribute, potentially causing unexpected behavior due to attribute overriding conflicts.
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

// Determines if a Python function contains only pass statements and docstrings
predicate is_empty_function(PyFunctionObject f) {
  // Verify function body contains no non-pass statements or expressions beyond docstrings
  not exists(Stmt s | s.getScope() = f.getFunction() |
    not s instanceof Pass and not s.(ExprStmt).getValue() = f.getFunction().getDocString()
  )
}

// Checks if a method explicitly calls super() to invoke parent class implementation
predicate invokes_super(FunctionObject f) {
  // Identify super() calls within the function body
  exists(Call supCall, Call methodCall, Attribute attrRef, GlobalVariable superVar |
    methodCall.getScope() = f.getFunction() and
    methodCall.getFunc() = attrRef and
    attrRef.getObject() = supCall and
    attrRef.getName() = f.getName() and
    supCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/** Identifies attribute names exempt from conflict detection due to special framework requirements */
predicate is_exempt_name(string name) {
  /*
   * Special case exemption for socketserver framework:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  name = "process_request"
}

from
  ClassObject derivedClass, ClassObject baseClass1, ClassObject baseClass2, 
  string attributeName, int baseIndex1, int baseIndex2, 
  Object attribute1, Object attribute2
where
  // Establish inheritance hierarchy with ordered base classes
  derivedClass.getBaseType(baseIndex1) = baseClass1 and
  derivedClass.getBaseType(baseIndex2) = baseClass2 and
  baseIndex1 < baseIndex2 and
  
  // Verify conflicting attributes exist in different base classes
  attribute1 = baseClass1.lookupAttribute(attributeName) and
  attribute2 = baseClass2.lookupAttribute(attributeName) and
  attribute1 != attribute2 and
  
  // Exclude special naming patterns and exempted attributes
  not attributeName.matches("\\_\\_%\\_\\_") and
  not is_exempt_name(attributeName) and
  
  // Ensure derived class doesn't override the attribute
  not derivedClass.declaresAttribute(attributeName) and
  
  // Validate attribute implementations don't resolve conflicts
  not invokes_super(attribute1) and
  not is_empty_function(attribute2) and
  not attribute1.overrides(attribute2) and
  not attribute2.overrides(attribute1)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attribute1, attribute1.toString(), 
  attribute2, attribute2.toString()