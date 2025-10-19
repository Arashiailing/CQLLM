/**
 * @name Unused import
 * @description Import is not required as it is not used
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/unused-import */

import python
import Variables.Definition
import semmle.python.ApiGraphs

/**
 * Checks if an import is used as a pytest fixture decorator
 * Detects functions decorated with pytest.fixture which should not be considered unused
 */
private predicate is_pytest_fixture(Import importDeclaration, Variable importedVariable) {
  exists(Alias alias, API::Node fixtureNode, API::Node decoratorNode |
    // Get pytest.fixture decorator node
    fixtureNode = API::moduleImport("pytest").getMember("fixture") and
    // Handle both direct fixture usage and its return value usage
    decoratorNode in [fixtureNode, fixtureNode.getReturn()] and
    // Get imported alias
    alias = importDeclaration.getAName() and
    // Associate imported variable name
    alias.getAsname().(Name).getVariable() = importedVariable and
    // Verify alias value matches decorator return value
    alias.getValue() = decoratorNode.getReturn().getAValueReachableFromSource().asExpr()
  )
}

/**
 * Checks if a global name is used within a module
 * Includes both direct global variable usage and local variable usage in non-function scopes
 */
predicate global_name_used(Module moduleScope, string identifier) {
  // Check direct global variable usage
  exists(Name usageNode, GlobalVariable globalVar |
    usageNode.uses(globalVar) and
    globalVar.getId() = identifier and
    usageNode.getEnclosingModule() = moduleScope
  )
  or
  // Check local variable usage in non-function scopes (which reference globals)
  exists(Name usageNode, LocalVariable localVar |
    usageNode.uses(localVar) and
    localVar.getId() = identifier and
    usageNode.getEnclosingModule() = moduleScope and
    not localVar.getScope().getEnclosingScope*() instanceof Function
  )
}

/**
 * Detects if a module has an opaque __all__ definition
 * Returns true when __all__ is not a simple list or is dynamically modified
 */
predicate all_not_understood(Module moduleScope) {
  exists(GlobalVariable allVar | 
    allVar.getId() = "__all__" and 
    allVar.getScope() = moduleScope and
    (
      // __all__ is not statically defined as a simple list
      not moduleScope.declaredInAll(_)
      or
      // __all__ is dynamically modified in code
      exists(Call modificationCall | 
        modificationCall.getFunc().(Attribute).getObject() = allVar.getALoad()
      )
    )
  )
}

/**
 * Checks if an imported module is used in doctests
 * Returns true if the imported name appears in doctest examples
 */
predicate imported_module_used_in_doctest(Import importDeclaration) {
  exists(string importedName, string docstringContent |
    // Get imported name
    importDeclaration.getAName().getAsname().(Name).getId() = importedName and
    // Check if referenced in doctest
    docstringContent = doctest_in_scope(importDeclaration.getScope()) and
    docstringContent.regexpMatch("[\\s\\S]*(>>>|\\.\\.\\.).*" + importedName + "[\\s\\S]*")
  )
}

/**
 * Retrieves doctest string content within a given scope
 * Marked noinline to prevent function inlining for performance
 */
pragma[noinline]
private string doctest_in_scope(Scope scope) {
  exists(StringLiteral docLiteral |
    docLiteral.getEnclosingModule() = scope and
    docLiteral.isDocString() and
    result = docLiteral.getText() and
    result.regexpMatch("[\\s\\S]*(>>>|\\.\\.\\.)[\\s\\S]*")
  )
}

/**
 * Retrieves type hint annotations appearing as strings in a module
 * Typically used for forward references, marked noinline for performance
 */
pragma[noinline]
private string typehint_annotation_in_module(Module moduleScope) {
  exists(StringLiteral typeAnnotation |
    (
      // Check function parameter type annotations
      typeAnnotation = any(Arguments args).getAnAnnotation().getASubExpression*()
      or
      // Check variable annotation type hints
      typeAnnotation = any(AnnAssign annAssign).getAnnotation().getASubExpression*()
      or
      // Check function return type annotations
      typeAnnotation = any(FunctionExpr func).getReturns().getASubExpression*()
    ) and
    typeAnnotation.pointsTo(Value::forString(result)) and
    typeAnnotation.getEnclosingModule() = moduleScope
  )
}

/**
 * Retrieves type hint comments in a file
 * Comments starting with "# type:", marked noinline for performance
 */
pragma[noinline]
private string typehint_comment_in_file(File file) {
  exists(Comment typeComment |
    file = typeComment.getLocation().getFile() and
    result = typeComment.getText() and
    result.matches("# type:%")
  )
}

/**
 * Checks if an imported alias is used in type hints
 * Includes both type annotations and string-form type hints (for forward references)
 */
predicate imported_alias_used_in_typehint(Import importDeclaration, Variable importedVariable) {
  importDeclaration.getAName().getAsname().(Name).getVariable() = importedVariable and
  exists(File file, Module moduleScope |
    moduleScope = importDeclaration.getEnclosingModule() and
    file = moduleScope.getFile()
  |
    // Check usage in type comments
    typehint_comment_in_file(file).regexpMatch("# type:.*" + importedVariable.getId() + ".*")
    or
    // Check usage in string-form type hints
    typehint_annotation_in_module(moduleScope).regexpMatch(".*\\b" + importedVariable.getId() + "\\b.*")
  )
}

/**
 * Determines if an import is unused
 * Combines multiple conditions to exclude special cases, ensuring only truly unused imports are reported
 */
predicate unused_import(Import importDeclaration, Variable importedVariable) {
  // Basic conditions: imported variable exists and not __future__ import
  importDeclaration.getAName().getAsname().(Name).getVariable() = importedVariable and
  not importDeclaration.getAnImportedModuleName() = "__future__" and
  
  // Scope condition: import is at module level
  importDeclaration.getScope() = importDeclaration.getEnclosingModule() and
  
  // Usage condition: variable not used globally
  not global_name_used(importDeclaration.getScope(), importedVariable.getId()) and
  
  // Special case exclusions:
  // 1. Declared in __all__
  not importDeclaration.getEnclosingModule().declaredInAll(importedVariable.getId()) and
  // 2. Package __init__.py imports for forced module loading
  not importDeclaration.getEnclosingModule().isPackageInit() and
  // 3. Epytext documentation usage
  not exists(Comment docComment | 
    docComment.getText().matches("%L{" + importedVariable.getId() + "}%") and
    docComment.getLocation().getFile() = importDeclaration.getLocation().getFile()
  ) and
  // 4. Unused variable naming convention (e.g., _ or __)
  not name_acceptable_for_unused_variable(importedVariable) and
  // 5. Opaque __all__ definition
  not all_not_understood(importDeclaration.getEnclosingModule()) and
  // 6. Doctest usage
  not imported_module_used_in_doctest(importDeclaration) and
  // 7. Type hint usage
  not imported_alias_used_in_typehint(importDeclaration, importedVariable) and
  // 8. Pytest fixture import
  not is_pytest_fixture(importDeclaration, importedVariable) and
  
  // Ensure import points to a value (possibly unknown module)
  importDeclaration.getAName().getValue().pointsTo(_)
}

/**
 * Main query: Finds and reports unused import statements
 * Outputs unused import statements and their names
 */
from Import importDeclaration, Variable importedVariable
where unused_import(importDeclaration, importedVariable)
select importDeclaration, "Import of '" + importedVariable.getId() + "' is not used."