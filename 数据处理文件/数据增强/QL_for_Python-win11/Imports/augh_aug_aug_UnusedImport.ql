/**
 * @name Unused import
 * @description Identifies import statements that are never referenced in the code
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
 * Checks if an import is used as a pytest fixture decorator.
 * Excludes imports that decorate functions with @pytest.fixture from being flagged as unused.
 */
private predicate is_pytest_fixture_decorator(Import importStmt, Variable importedVar) {
  exists(Alias alias, API::Node fixtureNode, API::Node decoratorNode |
    // Identify pytest.fixture decorator node
    fixtureNode = API::moduleImport("pytest").getMember("fixture") and
    // Handle both direct fixture usage and its return value
    decoratorNode in [fixtureNode, fixtureNode.getReturn()] and
    // Get the import alias
    alias = importStmt.getAName() and
    // Link imported variable to alias
    alias.getAsname().(Name).getVariable() = importedVar and
    // Verify alias matches decorator return value
    alias.getValue() = decoratorNode.getReturn().getAValueReachableFromSource().asExpr()
  )
}

/**
 * Determines if a global name is referenced within a module.
 * Covers both direct global variable usage and local variables in non-function scopes.
 */
predicate is_global_name_referenced(Module moduleScope, string nameStr) {
  // Direct global variable usage
  exists(Name usageNode, GlobalVariable globalVar |
    usageNode.uses(globalVar) and
    globalVar.getId() = nameStr and
    usageNode.getEnclosingModule() = moduleScope
  )
  or
  // Local variables in non-function scopes (which reference globals)
  exists(Name usageNode, LocalVariable localVar |
    usageNode.uses(localVar) and
    localVar.getId() = nameStr and
    usageNode.getEnclosingModule() = moduleScope and
    not localVar.getScope().getEnclosingScope*() instanceof Function
  )
}

/**
 * Detects modules with statically unanalyzable `__all__` definitions.
 * Excludes modules where `__all__` is not a simple list or is dynamically modified.
 */
predicate has_opaque_all_definition(Module moduleScope) {
  exists(GlobalVariable allVar | 
    allVar.getId() = "__all__" and 
    allVar.getScope() = moduleScope and
    (
      // `__all__` is not a statically defined simple list
      not moduleScope.declaredInAll(_)
      or
      // `__all__` is dynamically modified
      exists(Call modifyCall | 
        modifyCall.getFunc().(Attribute).getObject() = allVar.getALoad()
      )
    )
  )
}

/**
 * Checks if an imported name appears in doctest examples.
 * Excludes imports referenced in doctest examples from being flagged as unused.
 */
predicate is_import_used_in_doctest(Import importStmt) {
  exists(string importedName, string docstringContent |
    // Get imported name
    importStmt.getAName().getAsname().(Name).getId() = importedName and
    // Check doctest references
    docstringContent = get_doctest_content_in_scope(importStmt.getScope()) and
    docstringContent.regexpMatch("[\\s\\S]*(>>>|\\.\\.\\.).*" + importedName + "[\\s\\S]*")
  )
}

/**
 * Retrieves doctest content within a specified scope.
 * Marked noinline to prevent function inlining and maintain performance.
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
 * Retrieves string-form type hint annotations in a module.
 * Typically used for forward references. Marked noinline for performance.
 */
pragma[noinline]
private string get_typehint_annotation_in_module(Module moduleScope) {
  exists(StringLiteral typeAnnotation |
    (
      // Function parameter type annotations
      typeAnnotation = any(Arguments args).getAnAnnotation().getASubExpression*()
      or
      // Variable type annotations
      typeAnnotation = any(AnnAssign annAssign).getAnnotation().getASubExpression*()
      or
      // Function return type annotations
      typeAnnotation = any(FunctionExpr func).getReturns().getASubExpression*()
    ) and
    typeAnnotation.pointsTo(Value::forString(result)) and
    typeAnnotation.getEnclosingModule() = moduleScope
  )
}

/**
 * Retrieves type hint comments in a file.
 * Comments starting with "# type:". Marked noinline for performance.
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
 * Includes both type annotations and string-form type hints.
 */
predicate is_import_alias_used_in_typehint(Import importStmt, Variable importedVar) {
  importStmt.getAName().getAsname().(Name).getVariable() = importedVar and
  exists(File file, Module moduleScope |
    moduleScope = importStmt.getEnclosingModule() and
    file = moduleScope.getFile()
  |
    // Check type hint comments
    get_typehint_comment_in_file(file).regexpMatch("# type:.*" + importedVar.getId() + ".*")
    or
    // Check string-form type hints
    get_typehint_annotation_in_module(moduleScope).regexpMatch(".*\\b" + importedVar.getId() + "\\b.*")
  )
}

/**
 * Determines if an import is unused by excluding special cases.
 * Combines multiple conditions to identify truly unused imports.
 */
predicate is_import_unused(Import importStmt, Variable importedVar) {
  // Basic conditions: valid import and not __future__
  importStmt.getAName().getAsname().(Name).getVariable() = importedVar and
  not importStmt.getAnImportedModuleName() = "__future__" and
  
  // Scope condition: module-level import
  importStmt.getScope() = importStmt.getEnclosingModule() and
  
  // Usage condition: no global references
  not is_global_name_referenced(importStmt.getScope(), importedVar.getId()) and
  
  // Special case exclusions:
  // 1. Import declared in __all__
  not importStmt.getEnclosingModule().declaredInAll(importedVar.getId()) and
  // 2. Imports in __init__.py for module loading
  not importStmt.getEnclosingModule().isPackageInit() and
  // 3. Imports used in epytext documentation
  not exists(Comment docComment | 
    docComment.getText().matches("%L{" + importedVar.getId() + "}%") and
    docComment.getLocation().getFile() = importStmt.getLocation().getFile()
  ) and
  // 4. Unused naming conventions (e.g., _ or __)
  not name_acceptable_for_unused_variable(importedVar) and
  // 5. Opaque __all__ definitions
  not has_opaque_all_definition(importStmt.getEnclosingModule()) and
  // 6. Doctest usage
  not is_import_used_in_doctest(importStmt) and
  // 7. Type hint usage
  not is_import_alias_used_in_typehint(importStmt, importedVar) and
  // 8. Pytest fixture usage
  not is_pytest_fixture_decorator(importStmt, importedVar) and
  
  // Ensure import points to a value (possibly unknown module)
  importStmt.getAName().getValue().pointsTo(_)
}

/**
 * Main query: Identifies and reports unused import statements.
 * Outputs unused imports with their corresponding names.
 */
from Import importStmt, Variable importedVar
where is_import_unused(importStmt, importedVar)
select importStmt, "Import of '" + importedVar.getId() + "' is not used."