/**
 * @name Unused import
 * @description Identifies imported modules that are never referenced in the codebase
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/unused-import
 */

// Core Python analysis modules
import python
import Variables.Definition
import semmle.python.ApiGraphs

// Determines if an import represents a pytest fixture
private predicate is_pytest_fixture(Import importDeclaration, Variable fixtureVariable) {
  exists(Alias importAlias, API::Node fixtureNode, API::Node decoratorNode |
    // Identify pytest.fixture decorator node
    fixtureNode = API::moduleImport("pytest").getMember("fixture") and
    // Consider both fixture node and its return value as decorators
    decoratorNode in [fixtureNode, fixtureNode.getReturn()] and
    // Get alias from import declaration
    importAlias = importDeclaration.getAName() and
    // Verify alias refers to fixture variable
    importAlias.getAsname().(Name).getVariable() = fixtureVariable and
    // Confirm alias value derives from decorator node
    importAlias.getValue() = decoratorNode.getReturn().getAValueReachableFromSource().asExpr()
  )
}

// Checks if a global identifier is referenced within a module
predicate global_name_used(Module targetModule, string identifierString) {
  // Case 1: Direct usage as global variable
  exists(Name usageNode, GlobalVariable globalVariable |
    usageNode.uses(globalVariable) and
    globalVariable.getId() = identifierString and
    usageNode.getEnclosingModule() = targetModule
  )
  or
  // Case 2: Usage as local variable outside function scope
  exists(Name usageNode, LocalVariable localVariable |
    usageNode.uses(localVariable) and
    localVariable.getId() = identifierString and
    usageNode.getEnclosingModule() = targetModule and
    // Ensure variable is not inside function scope
    not localVariable.getScope().getEnclosingScope*() instanceof Function
  )
}

/** Holds if module has an incompletely analyzable `__all__` variable */
predicate all_not_understood(Module targetModule) {
  exists(GlobalVariable allVariable | 
    allVariable.getId() = "__all__" and 
    allVariable.getScope() = targetModule and
    (
      // Module's __all__ not defined as analyzable list
      not targetModule.declaredInAll(_)
      or
      // __all__ variable is modified (e.g., via append)
      exists(Call modifyingCall | 
        modifyingCall.getFunc().(Attribute).getObject() = allVariable.getALoad()
      )
    )
  )
}

// Checks if imported module is referenced in doctest strings
predicate imported_module_used_in_doctest(Import importDeclaration) {
  exists(string moduleName, string docStringContent |
    // Extract imported module name from alias
    importDeclaration.getAName().getAsname().(Name).getId() = moduleName and
    // Retrieve doctest string in same scope
    docStringContent = doctest_in_scope(importDeclaration.getScope()) and
    // Verify doctest contains module reference
    docStringContent.regexpMatch("[\\s\\S]*(>>>|\\.\\.\\.).*" + moduleName + "[\\s\\S]*")
  )
}

// pragma[noinline]: Extracts doctest string from given scope
pragma[noinline]
private string doctest_in_scope(Scope targetScope) {
  exists(StringLiteral docLiteralNode |
    // Docstring must be in specified scope
    docLiteralNode.getEnclosingModule() = targetScope and
    docLiteralNode.isDocString() and
    // Docstring text must contain doctest patterns
    result = docLiteralNode.getText() and
    result.regexpMatch("[\\s\\S]*(>>>|\\.\\.\\.)[\\s\\S]*")
  )
}

// pragma[noinline]: Extracts type hint annotations from module
pragma[noinline]
private string typehint_annotation_in_module(Module targetModule) {
  exists(StringLiteral typeHintNode |
    // Type hints can come from arguments, annotated assignments, or function returns
    (
      typeHintNode = any(Arguments funcArgs).getAnAnnotation().getASubExpression*()
      or
      typeHintNode = any(AnnAssign annotatedAssign).getAnnotation().getASubExpression*()
      or
      typeHintNode = any(FunctionExpr functionExpr).getReturns().getASubExpression*()
    ) and
    // Annotation must point to string value (for forward references)
    typeHintNode.pointsTo(Value::forString(result)) and
    // Annotation must be in specified module
    typeHintNode.getEnclosingModule() = targetModule
  )
}

// pragma[noinline]: Retrieves type hint comments from file
pragma[noinline]
private string typehint_comment_in_file(File sourceFile) {
  exists(Comment hintComment |
    // Comment must be in specified file
    sourceFile = hintComment.getLocation().getFile() and
    // Comment text must be type hint comment
    result = hintComment.getText() and
    result.matches("# type:%")
  )
}

/** Holds if imported alias is used in type hints within same file */
predicate imported_alias_used_in_typehint(Import importDeclaration, Variable importedVariable) {
  // Import alias must refer to specified variable
  importDeclaration.getAName().getAsname().(Name).getVariable() = importedVariable and
  exists(File sourceFile, Module targetModule |
    // Get module and file from import declaration
    targetModule = importDeclaration.getEnclosingModule() and
    sourceFile = targetModule.getFile()
  |
    // Check if alias is used in type hint comment
    typehint_comment_in_file(sourceFile).regexpMatch("# type:.*" + importedVariable.getId() + ".*")
    or
    // Check if alias is used in string annotation (forward references)
    typehint_annotation_in_module(targetModule).regexpMatch(".*\\b" + importedVariable.getId() + "\\b.*")
  )
}

// Identifies imports that are never referenced in the code
predicate unused_import(Import importDeclaration, Variable importedVariable) {
  // Import must have alias referring to specified variable
  importDeclaration.getAName().getAsname().(Name).getVariable() = importedVariable and
  // Exclude __future__ imports (special handling)
  not importDeclaration.getAnImportedModuleName() = "__future__" and
  // Import must be at module level
  importDeclaration.getScope() = importDeclaration.getEnclosingModule() and
  // Imported name not in module's __all__ (if analyzable)
  not importDeclaration.getEnclosingModule().declaredInAll(importedVariable.getId()) and
  // Name not used as global variable
  not global_name_used(importDeclaration.getScope(), importedVariable.getId()) and
  // Exclude imports in __init__.py files (package loading)
  not importDeclaration.getEnclosingModule().isPackageInit() and
  // Name not referenced in epytext documentation comments
  not exists(Comment docComment | 
    docComment.getText().matches("%L{" + importedVariable.getId() + "}%") and
    docComment.getLocation().getFile() = importDeclaration.getLocation().getFile()
  ) and
  // Name not acceptable for unused variables (e.g., _)
  not name_acceptable_for_unused_variable(importedVariable) and
  // Module doesn't have unanalyzable __all__ (which might include name)
  not all_not_understood(importDeclaration.getEnclosingModule()) and
  // Imported module not used in doctests
  not imported_module_used_in_doctest(importDeclaration) and
  // Alias not used in type hints
  not imported_alias_used_in_typehint(importDeclaration, importedVariable) and
  // Import not a pytest fixture
  not is_pytest_fixture(importDeclaration, importedVariable) and
  // Import must resolve to something (not failed import)
  importDeclaration.getAName().getValue().pointsTo(_)
}

// Query statement to identify unused imports
from Stmt statement, Variable importedVariable
where unused_import(statement, importedVariable)
select statement, "Import of '" + importedVariable.getId() + "' is not used."