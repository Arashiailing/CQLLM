/**
 * @name Conflicting attributes in base classes
 * @description Detects when a class inherits from multiple base classes that define the same attribute, potentially causing unexpected behavior due to attribute resolution conflicts.
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

// Determines if a function contains only pass statements or docstrings
predicate is_empty_function(PyFunctionObject func) {
  // Verifies the function body contains no meaningful statements beyond pass or docstring
  not exists(Stmt statement | statement.getScope() = func.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/* Methods invoking super() are safe as they explicitly call overridden methods */
// Checks if a function contains a super() call
predicate invokes_super(FunctionObject func) {
  // Identifies super() method calls within the function body
  exists(Call superCall, Call methodCall, Attribute attrRef, GlobalVariable superVar |
    methodCall.getScope() = func.getFunction() and
    methodCall.getFunc() = attrRef and
    attrRef.getObject() = superCall and
    attrRef.getName() = func.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/** Identifies attribute names exempt from conflict detection */
predicate is_exempted(string attributeName) {
  /*
   * Exemption for specific library-recommended patterns:
   * See https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attributeName = "process_request"
}

from
  ClassObject derivedClass, 
  ClassObject baseClass1, 
  ClassObject baseClass2, 
  string attrName, 
  int index1, 
  int index2, 
  Object attrObj1, 
  Object attrObj2
where
  // Establish base class relationships with distinct indices
  derivedClass.getBaseType(index1) = baseClass1 and
  derivedClass.getBaseType(index2) = baseClass2 and
  index1 < index2 and
  
  // Retrieve conflicting attribute objects from base classes
  attrObj1 = baseClass1.lookupAttribute(attrName) and
  attrObj2 = baseClass2.lookupAttribute(attrName) and
  attrObj1 != attrObj2 and
  
  // Exclude special method names and exempted attributes
  not attrName.matches("\\_\\_%\\_\\_") and
  not is_exempted(attrName) and
  
  // Filter out safe resolution patterns
  not invokes_super(attrObj1) and
  not is_empty_function(attrObj2) and
  
  // Verify no override relationship exists between attributes
  not attrObj1.overrides(attrObj2) and
  not attrObj2.overrides(attrObj1) and
  
  // Ensure derived class doesn't explicitly declare the attribute
  not derivedClass.declaresAttribute(attrName)
select 
  derivedClass, 
  "Base classes have conflicting values for attribute '" + attrName + "': $@ and $@.", 
  attrObj1, attrObj1.toString(), 
  attrObj2, attrObj2.toString()