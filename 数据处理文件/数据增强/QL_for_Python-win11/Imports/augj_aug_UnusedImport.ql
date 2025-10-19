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
 * Identifies imports used as pytest fixture decorators.
 * Detects functions decorated with pytest.fixture which should not be flagged as unused.
 */
private predicate is_pytest_fixture_decorator(Import importDecl, Variable importedVar) {
  exists(Alias nameAlias, API::Node fixtureApiNode, API::Node decoratorApiNode |
    // Retrieve the pytest.fixture decorator API node
    fixtureApiNode = API::moduleImport("pytest").getMember("fixture") and
    // Handle both direct fixture usage and usage of its return value
    decoratorApiNode in [fixtureApiNode, fixtureApiNode.getReturn()] and
    // Get the import alias
    nameAlias = importDecl.getAName() and
    // Associate with the imported variable
    nameAlias.getAsname().(Name).getVariable() = importedVar and
    // Verify that the alias value matches the decorator return value
    nameAlias.getValue() = decoratorApiNode.getReturn().getAValueReachableFromSource().asExpr()
  )
}

/**
 * Determines if a global name is referenced within a module.
 * Includes direct usage of global variables and local variables
 * referenced in non-function scopes (which effectively reference globals).
 */
predicate is_global_name_referenced(Module moduleCtx, string identifier) {
  // Check for direct usage of global variables
  exists(Name nameUsage, GlobalVariable globalVar |
    nameUsage.uses(globalVar) and
    globalVar.getId() = identifier and
    nameUsage.getEnclosingModule() = moduleCtx
  )
  or
  // Check for local variables used in non-function scopes
  exists(Name nameUsage, LocalVariable localVar |
    nameUsage.uses(localVar) and
    localVar.getId() = identifier and
    nameUsage.getEnclosingModule() = moduleCtx and
    not localVar.getScope().getEnclosingScope*() instanceof Function
  )
}

/**
 * Detects modules with non-analyzable `__all__` definitions.
 * When `__all__` is not a simple list or is dynamically modified,
 * we cannot reliably determine if imports are actually used.
 */
predicate has_opaque_all_definition(Module moduleCtx) {
  exists(GlobalVariable allVar | 
    allVar.getId() = "__all__" and 
    allVar.getScope() = moduleCtx and
    (
      // `__all__` is not statically defined as a simple list
      not moduleCtx.declaredInAll(_)
      or
      // `__all__` is dynamically modified in the code
      exists(Call modCall | 
        modCall.getFunc().(Attribute).getObject() = allVar.getALoad()
      )
    )
  )
}

/**
 * Checks if an imported module is referenced in doctest examples.
 * Imports appearing in doctest examples should not be considered unused.
 */
predicate is_import_used_in_doctest(Import importDecl) {
  exists(string importedName, string docText |
    // Get the imported name
    importDecl.getAName().getAsname().(Name).getId() = importedName and
    // Check if the name appears in doctest content
    docText = extract_doctest_content(importDecl.getScope()) and
    docText.regexpMatch("[\\s\\S]*(>>>|\\.\\.\\.).*" + importedName + "[\\s\\S]*")
  )
}

/**
 * Extracts doctest content within a specified scope.
 * Marked noinline to prevent function inlining for performance optimization.
 */
pragma[noinline]
private string extract_doctest_content(Scope scopeCtx) {
  exists(StringLiteral docLiteral |
    docLiteral.getEnclosingModule() = scopeCtx and
    docLiteral.isDocString() and
    result = docLiteral.getText() and
    result.regexpMatch("[\\s\\S]*(>>>|\\.\\.\\.)[\\s\\S]*")
  )
}

/**
 * Retrieves string-based type hint annotations in a module.
 * These are typically used for forward references.
 * Marked noinline for performance optimization.
 */
pragma[noinline]
private string get_string_typehint_annotation(Module moduleCtx) {
  exists(StringLiteral typeAnnot |
    (
      // Check function parameter type annotations
      typeAnnot = any(Arguments args).getAnAnnotation().getASubExpression*()
      or
      // Check variable annotation type annotations
      typeAnnot = any(AnnAssign annAssign).getAnnotation().getASubExpression*()
      or
      // Check function return type annotations
      typeAnnot = any(FunctionExpr func).getReturns().getASubExpression*()
    ) and
    typeAnnot.pointsTo(Value::forString(result)) and
    typeAnnot.getEnclosingModule() = moduleCtx
  )
}

/**
 * Retrieves type hint comments in a file.
 * These are comments starting with "# type:".
 * Marked noinline for performance optimization.
 */
pragma[noinline]
private string get_typehint_comment(File fileCtx) {
  exists(Comment typeComment |
    fileCtx = typeComment.getLocation().getFile() and
    result = typeComment.getText() and
    result.matches("# type:%")
  )
}

/**
 * Determines if an imported alias is used in type hints.
 * This includes both type annotations and string-form type hints
 * (commonly used for forward references).
 */
predicate is_import_alias_used_in_typehint(Import importDecl, Variable importedVar) {
  importDecl.getAName().getAsname().(Name).getVariable() = importedVar and
  exists(File sourceFile, Module moduleCtx |
    moduleCtx = importDecl.getEnclosingModule() and
    sourceFile = moduleCtx.getFile()
  |
    // Check if the import is referenced in type comments
    get_typehint_comment(sourceFile).regexpMatch("# type:.*" + importedVar.getId() + ".*")
    or
    // Check if the import is referenced in string-form type hints
    get_string_typehint_annotation(moduleCtx).regexpMatch(".*\\b" + importedVar.getId() + "\\b.*")
  )
}

/**
 * Determines if an import is unused.
 * Combines multiple conditions to exclude special cases,
 * ensuring only truly unused imports are reported.
 */
predicate is_import_unused(Import importDecl, Variable importedVar) {
  // Basic conditions: the imported variable exists and is not a __future__ import
  importDecl.getAName().getAsname().(Name).getVariable() = importedVar and
  not importDecl.getAnImportedModuleName() = "__future__" and
  
  // Scope condition: the import is at module level
  importDecl.getScope() = importDecl.getEnclosingModule() and
  
  // Usage condition: the variable is not globally referenced
  not is_global_name_referenced(importDecl.getScope(), importedVar.getId()) and
  
  // Exclude special cases:
  // 1. Imports declared in __all__
  not importDecl.getEnclosingModule().declaredInAll(importedVar.getId()) and
  // 2. Imports in __init__.py used for forced module loading
  not importDecl.getEnclosingModule().isPackageInit() and
  // 3. Imports used in epytext documentation
  not exists(Comment docComment | 
    docComment.getText().matches("%L{" + importedVar.getId() + "}%") and
    docComment.getLocation().getFile() = importDecl.getLocation().getFile()
  ) and
  // 4. Variables following unused variable naming conventions (like _ or __)
  not name_acceptable_for_unused_variable(importedVar) and
  // 5. Modules with opaque __all__ definitions
  not has_opaque_all_definition(importDecl.getEnclosingModule()) and
  // 6. Imports used in doctest
  not is_import_used_in_doctest(importDecl) and
  // 7. Imports used in type hints
  not is_import_alias_used_in_typehint(importDecl, importedVar) and
  // 8. pytest fixture imports
  not is_pytest_fixture_decorator(importDecl, importedVar) and
  
  // Ensure the import actually points to a value (possibly an unknown module)
  importDecl.getAName().getValue().pointsTo(_)
}

/**
 * Main query: Find and report unused import statements.
 * Outputs unused import statements along with their names.
 */
from Import importDecl, Variable importedVar
where is_import_unused(importDecl, importedVar)
select importDecl, "Import of '" + importedVar.getId() + "' is not used."