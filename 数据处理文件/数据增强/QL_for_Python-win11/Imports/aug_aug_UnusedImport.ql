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
 * Determines if an import is used as a pytest fixture decorator.
 * Detects functions decorated with pytest.fixture, which should not be considered unused.
 */
private predicate is_pytest_fixture_decorator(Import imp, Variable importedName) {
  exists(Alias alias, API::Node fixtureNode, API::Node decoratorNode |
    // Get the pytest.fixture decorator node
    fixtureNode = API::moduleImport("pytest").getMember("fixture") and
    // Handle both direct fixture usage and its return value
    decoratorNode in [fixtureNode, fixtureNode.getReturn()] and
    // Get the import alias
    alias = imp.getAName() and
    // Associate the imported variable name
    alias.getAsname().(Name).getVariable() = importedName and
    // Verify the alias value matches the decorator return value
    alias.getValue() = decoratorNode.getReturn().getAValueReachableFromSource().asExpr()
  )
}

/**
 * Checks if a global name is used within a module.
 * Includes both direct global variable usage and local variables used in non-function scopes.
 */
predicate is_global_name_referenced(Module moduleScope, string nameStr) {
  // Check direct global variable usage
  exists(Name usageNode, GlobalVariable globalVar |
    usageNode.uses(globalVar) and
    globalVar.getId() = nameStr and
    usageNode.getEnclosingModule() = moduleScope
  )
  or
  // Check local variables used in non-function scopes (which reference global variables)
  exists(Name usageNode, LocalVariable localVar |
    usageNode.uses(localVar) and
    localVar.getId() = nameStr and
    usageNode.getEnclosingModule() = moduleScope and
    not localVar.getScope().getEnclosingScope*() instanceof Function
  )
}

/**
 * Detects if a module has a statically unanalyzable `__all__` definition.
 * If `__all__` is not a simple list or is dynamically modified, we cannot determine if imports are used.
 */
predicate has_opaque_all_definition(Module moduleScope) {
  exists(GlobalVariable allVar | 
    allVar.getId() = "__all__" and 
    allVar.getScope() = moduleScope and
    (
      // `__all__` is not a statically defined simple list
      not moduleScope.declaredInAll(_)
      or
      // `__all__` is dynamically modified in the code
      exists(Call modifyCall | 
        modifyCall.getFunc().(Attribute).getObject() = allVar.getALoad()
      )
    )
  )
}

/**
 * Checks if an imported module is used in doctest examples.
 * If the imported name appears in doctest examples, it should not be considered unused.
 */
predicate is_import_used_in_doctest(Import importStmt) {
  exists(string importedName, string docstringContent |
    // Get the imported name
    importStmt.getAName().getAsname().(Name).getId() = importedName and
    // Check if the import is referenced in doctest
    docstringContent = get_doctest_content_in_scope(importStmt.getScope()) and
    docstringContent.regexpMatch("[\\s\\S]*(>>>|\\.\\.\\.).*" + importedName + "[\\s\\S]*")
  )
}

/**
 * Retrieves doctest string content within a specified scope.
 * Marked as noinline to prevent function inlining and maintain query performance.
 */
pragma[noinline]
private string get_doctest_content_in_scope(Scope scope) {
  exists(StringLiteral docLiteral |
    docLiteral.getEnclosingModule() = scope and
    docLiteral.isDocString() and
    result = docLiteral.getText() and
    result.regexpMatch("[\\s\\S]*(>>>|\\.\\.\\.)[\\s\\S]*")
  )
}

/**
 * Retrieves type hint annotations appearing as strings in a module.
 * These are typically used for forward references. Marked as noinline for performance optimization.
 */
pragma[noinline]
private string get_typehint_annotation_in_module(Module moduleScope) {
  exists(StringLiteral typeAnnotation |
    (
      // Check type annotations for function parameters
      typeAnnotation = any(Arguments args).getAnAnnotation().getASubExpression*()
      or
      // Check type annotations for variable annotations
      typeAnnotation = any(AnnAssign annAssign).getAnnotation().getASubExpression*()
      or
      // Check type annotations for function return values
      typeAnnotation = any(FunctionExpr func).getReturns().getASubExpression*()
    ) and
    typeAnnotation.pointsTo(Value::forString(result)) and
    typeAnnotation.getEnclosingModule() = moduleScope
  )
}

/**
 * Retrieves type hint comments in a file.
 * These are comments starting with "# type:". Marked as noinline for performance optimization.
 */
pragma[noinline]
private string get_typehint_comment_in_file(File file) {
  exists(Comment typeComment |
    file = typeComment.getLocation().getFile() and
    result = typeComment.getText() and
    result.matches("# type:%")
  )
}

/**
 * Checks if an imported alias is used in type hints.
 * Includes both type annotations and string-form type hints (used for forward references).
 */
predicate is_import_alias_used_in_typehint(Import importStmt, Variable importedVar) {
  importStmt.getAName().getAsname().(Name).getVariable() = importedVar and
  exists(File file, Module moduleScope |
    moduleScope = importStmt.getEnclosingModule() and
    file = moduleScope.getFile()
  |
    // Check if the import is used in type annotations
    get_typehint_comment_in_file(file).regexpMatch("# type:.*" + importedVar.getId() + ".*")
    or
    // Check if the import is used in string-form type hints
    get_typehint_annotation_in_module(moduleScope).regexpMatch(".*\\b" + importedVar.getId() + "\\b.*")
  )
}

/**
 * Determines if an import is unused.
 * Combines multiple conditions to exclude special cases, ensuring only truly unused imports are reported.
 */
predicate is_import_unused(Import importStmt, Variable importedVar) {
  // Basic conditions: imported variable exists and is not a __future__ import
  importStmt.getAName().getAsname().(Name).getVariable() = importedVar and
  not importStmt.getAnImportedModuleName() = "__future__" and
  
  // Scope condition: import is at module level
  importStmt.getScope() = importStmt.getEnclosingModule() and
  
  // Usage condition: variable is not used globally
  not is_global_name_referenced(importStmt.getScope(), importedVar.getId()) and
  
  // Exclude special cases:
  // 1. Import declared in __all__
  not importStmt.getEnclosingModule().declaredInAll(importedVar.getId()) and
  // 2. Imports in __init__.py used to force module loading
  not importStmt.getEnclosingModule().isPackageInit() and
  // 3. Imports used in epytext documentation
  not exists(Comment docComment | 
    docComment.getText().matches("%L{" + importedVar.getId() + "}%") and
    docComment.getLocation().getFile() = importStmt.getLocation().getFile()
  ) and
  // 4. Variables following unused variable naming conventions (like _ or __)
  not name_acceptable_for_unused_variable(importedVar) and
  // 5. Module has an opaque __all__ definition
  not has_opaque_all_definition(importStmt.getEnclosingModule()) and
  // 6. Imports used in doctest
  not is_import_used_in_doctest(importStmt) and
  // 7. Imports used in type hints
  not is_import_alias_used_in_typehint(importStmt, importedVar) and
  // 8. pytest fixture imports
  not is_pytest_fixture_decorator(importStmt, importedVar) and
  
  // Ensure the import actually points to a value (possibly unknown module)
  importStmt.getAName().getValue().pointsTo(_)
}

/**
 * Main query: Finds and reports unused import statements.
 * Outputs unused import statements and their names.
 */
from Import importStmt, Variable importedVar
where is_import_unused(importStmt, importedVar)
select importStmt, "Import of '" + importedVar.getId() + "' is not used."