/**
 * @name Incomplete ordering
 * @description Class defines one or more ordering method but does not define all 4 ordering comparison methods
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/incomplete-ordering
 */

import python

// Determines if a class has the @total_ordering decorator applied
predicate hasTotalOrderingDecorator(Class cls) {
  exists(Attribute decorator | decorator = cls.getADecorator() | decorator.getName() = "total_ordering") // Check for decorator attribute
  or
  exists(Name decoratorName | decoratorName = cls.getADecorator() | decoratorName.getId() = "total_ordering") // Check for decorator name
}

// Maps an index to the corresponding comparison method name
string comparisonMethodName(int index) {
  index = 1 and result = "__lt__" // Less than method
  or
  index = 2 and result = "__le__" // Less than or equal method
  or
  index = 3 and result = "__gt__" // Greater than method
  or
  index = 4 and result = "__ge__" // Greater than or equal method
}

// Checks if a class or its superclass implements a specific comparison method
predicate classImplementsComparisonMethod(ClassValue subjectClass, string methodName) {
  methodName = comparisonMethodName(_) and ( // Verify valid comparison method name
    subjectClass.declaresAttribute(methodName) // Check if class directly implements the method
    or
    exists(ClassValue ancestor | ancestor = subjectClass.getASuperType() and not ancestor = Value::named("object") | // Check superclass (excluding object)
      ancestor.declaresAttribute(methodName)
    )
  )
}

// Retrieves the name of a comparison method not implemented by the class
string missingComparisonMethod(ClassValue subjectClass, int index) {
  not subjectClass = Value::named("object") and // Exclude the base object class
  not classImplementsComparisonMethod(subjectClass, result) and // Ensure method is not implemented
  result = comparisonMethodName(index) // Get method name for the index
}

// Constructs a string listing all missing comparison methods
string formatMissingMethods(ClassValue subjectClass, int index) {
  index = 0 and result = "" and exists(missingComparisonMethod(subjectClass, _)) // Initialize and check for missing methods
  or
  exists(string accumulated, int prevIndex | index = prevIndex + 1 and accumulated = formatMissingMethods(subjectClass, prevIndex) | // Recursively build string
    accumulated = "" and result = missingComparisonMethod(subjectClass, index) // First method in list
    or
    result = accumulated and not exists(missingComparisonMethod(subjectClass, index)) and index < 5 // Skip implemented methods
    or
    accumulated != "" and result = accumulated + " or " + missingComparisonMethod(subjectClass, index) // Add separator and next method
  )
}

// Retrieves a comparison method declared by the class
Value getExplicitComparisonMethod(ClassValue subjectClass, string methodName) {
  /* If class doesn't declare a method then don't blame this class (the superclass will be blamed). */
  methodName = comparisonMethodName(_) and result = subjectClass.declaredAttribute(methodName) // Return declared method
}

// Main query to find classes with incomplete ordering methods
from ClassValue subjectClass, Value comparisonMethod, string methodName
where
  not subjectClass.failedInference(_) and // Exclude classes with inference failures
  not hasTotalOrderingDecorator(subjectClass.getScope()) and // Exclude classes using total_ordering decorator
  comparisonMethod = getExplicitComparisonMethod(subjectClass, methodName) and // Get a declared comparison method
  exists(missingComparisonMethod(subjectClass, _)) // Ensure there are missing methods
select subjectClass,
  "Class " + subjectClass.getName() + " implements $@, but does not implement " + // Report the issue
    formatMissingMethods(subjectClass, 4) + ".", comparisonMethod, methodName // List missing methods