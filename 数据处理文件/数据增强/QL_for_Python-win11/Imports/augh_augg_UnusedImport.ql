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
private predicate is_pytest_fixture(Import importDecl, Variable fixtureVar) {
  exists(Alias importAlias, API::Node fixtureNode, API::Node decoratorNode |
    // Identify pytest.fixture decorator node
    fixtureNode = API::moduleImport("pytest").getMember("fixture") and
    // Consider both fixture node and its return value as decorators
    decoratorNode in [fixtureNode, fixtureNode.getReturn()] and
    // Get alias from import declaration
    importAlias = importDecl.getAName() and
    // Verify alias refers to fixture variable
    importAlias.getAsname().(Name).getVariable() = fixtureVar and
    // Confirm alias value derives from decorator node
    importAlias.getValue() = decoratorNode.getReturn().getAValueReachableFromSource().asExpr()
  )
}

// Checks if a global identifier is referenced within a module
predicate global_name_used(Module mod, string idStr) {
  // Case 1: Direct usage as global variable
  exists(Name usage, GlobalVariable globalVar |
    usage.uses(globalVar) and
    globalVar.getId() = idStr and
    usage.getEnclosingModule() = mod
  )
  or
  // Case 2: Usage as local variable outside function scope
  exists(Name usage, LocalVariable localVar |
    usage.uses(localVar) and
    localVar.getId() = idStr and
    usage.getEnclosingModule() = mod and
    // Ensure variable is not inside function scope
    not localVar.getScope().getEnclosingScope*() instanceof Function
  )
}

/** Holds if module has an incompletely analyzable `__all__` variable */
predicate all_not_understood(Module mod) {
  exists(GlobalVariable allVariable | 
    allVariable.getId() = "__all__" and 
    allVariable.getScope() = mod and
    (
      // Module's __all__ not defined as analyzable list
      not mod.declaredInAll(_)
      or
      // __all__ variable is modified (e.g., via append)
      exists(Call modifyingCall | 
        modifyingCall.getFunc().(Attribute).getObject() = allVariable.getALoad()
      )
    )
  )
}

// Checks if imported module is referenced in doctest strings
predicate imported_module_used_in_doctest(Import importDecl) {
  exists(string modName, string docString |
    // Extract imported module name from alias
    importDecl.getAName().getAsname().(Name).getId() = modName and
    // Retrieve doctest string in same scope
    docString = doctest_in_scope(importDecl.getScope()) and
    // Verify doctest contains module reference
    docString.regexpMatch("[\\s\\S]*(>>>|\\.\\.\\.).*" + modName + "[\\s\\S]*")
  )
}

// pragma[noinline]: Extracts doctest string from given scope
pragma[noinline]
private string doctest_in_scope(Scope scope) {
  exists(StringLiteral docLiteralNode |
    // Docstring must be in specified scope
    docLiteralNode.getEnclosingModule() = scope and
    docLiteralNode.isDocString() and
    // Docstring text must contain doctest patterns
    result = docLiteralNode.getText() and
    result.regexpMatch("[\\s\\S]*(>>>|\\.\\.\\.)[\\s\\S]*")
  )
}

// pragma[noinline]: Extracts type hint annotations from module
pragma[noinline]
private string typehint_annotation_in_module(Module mod) {
  exists(StringLiteral typeHint |
    // Type hints can come from arguments, annotated assignments, or function returns
    (
      typeHint = any(Arguments funcArgs).getAnAnnotation().getASubExpression*()
      or
      typeHint = any(AnnAssign annotatedAssign).getAnnotation().getASubExpression*()
      or
      typeHint = any(FunctionExpr functionExpr).getReturns().getASubExpression*()
    ) and
    // Annotation must point to string value (for forward references)
    typeHint.pointsTo(Value::forString(result)) and
    // Annotation must be in specified module
    typeHint.getEnclosingModule() = mod
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
predicate imported_alias_used_in_typehint(Import importDecl, Variable importedName) {
  // Import alias must refer to specified variable
  importDecl.getAName().getAsname().(Name).getVariable() = importedName and
  exists(File sourceFile, Module mod |
    // Get module and file from import declaration
    mod = importDecl.getEnclosingModule() and
    sourceFile = mod.getFile()
  |
    // Check if alias is used in type hint comment
    typehint_comment_in_file(sourceFile).regexpMatch("# type:.*" + importedName.getId() + ".*")
    or
    // Check if alias is used in string annotation (forward references)
    typehint_annotation_in_module(mod).regexpMatch(".*\\b" + importedName.getId() + "\\b.*")
  )
}

// Identifies imports that are never referenced in the code
predicate unused_import(Import importDecl, Variable importedName) {
  // Import must have alias referring to specified variable
  importDecl.getAName().getAsname().(Name).getVariable() = importedName and
  // Exclude __future__ imports (special handling)
  not importDecl.getAnImportedModuleName() = "__future__" and
  // Import must be at module level
  importDecl.getScope() = importDecl.getEnclosingModule() and
  // Imported name not in module's __all__ (if analyzable)
  not importDecl.getEnclosingModule().declaredInAll(importedName.getId()) and
  // Name not used as global variable
  not global_name_used(importDecl.getScope(), importedName.getId()) and
  // Exclude imports in __init__.py files (package loading)
  not importDecl.getEnclosingModule().isPackageInit() and
  // Name not referenced in epytext documentation comments
  not exists(Comment docComment | 
    docComment.getText().matches("%L{" + importedName.getId() + "}%") and
    docComment.getLocation().getFile() = importDecl.getLocation().getFile()
  ) and
  // Name not acceptable for unused variables (e.g., _)
  not name_acceptable_for_unused_variable(importedName) and
  // Module doesn't have unanalyzable __all__ (which might include name)
  not all_not_understood(importDecl.getEnclosingModule()) and
  // Imported module not used in doctests
  not imported_module_used_in_doctest(importDecl) and
  // Alias not used in type hints
  not imported_alias_used_in_typehint(importDecl, importedName) and
  // Import not a pytest fixture
  not is_pytest_fixture(importDecl, importedName) and
  // Import must resolve to something (not failed import)
  importDecl.getAName().getValue().pointsTo(_)
}

// Query statement to identify unused imports
from Stmt stmt, Variable importedName
where unused_import(stmt, importedName)
select stmt, "Import of '" + importedName.getId() + "' is not used."