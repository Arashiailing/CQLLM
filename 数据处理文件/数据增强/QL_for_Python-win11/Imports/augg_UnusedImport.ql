/**
 * @name Unused import
 * @description Detects imports that are not used anywhere in the code
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

// Determines if an import is a pytest fixture
private predicate is_pytest_fixture(Import importStmt, Variable fixtureName) {
  exists(Alias alias, API::Node fixtureNode, API::Node decoratorNode |
    // Identify the pytest.fixture node
    fixtureNode = API::moduleImport("pytest").getMember("fixture") and
    // Consider both the fixture node and its return value as decorators
    decoratorNode in [fixtureNode, fixtureNode.getReturn()] and
    // Get the alias from the import statement
    alias = importStmt.getAName() and
    // Check if the alias refers to the given variable (fixture name)
    alias.getAsname().(Name).getVariable() = fixtureName and
    // Verify that the alias's value is derived from the decorator node
    alias.getValue() = decoratorNode.getReturn().getAValueReachableFromSource().asExpr()
  )
}

// Checks if a global name is used within a module
predicate global_name_used(Module moduleScope, string identifier) {
  // Case 1: The name is used as a global variable
  exists(Name usage, GlobalVariable variable |
    usage.uses(variable) and
    variable.getId() = identifier and
    usage.getEnclosingModule() = moduleScope
  )
  or
  // Case 2: The name is used as a local variable but in a non-function scope (thus effectively global)
  exists(Name usage, LocalVariable variable |
    usage.uses(variable) and
    variable.getId() = identifier and
    usage.getEnclosingModule() = moduleScope and
    // Ensure the variable is not inside a function
    not variable.getScope().getEnclosingScope*() instanceof Function
  )
}

/** Holds if the module has an `__all__` variable that we cannot fully analyze */
predicate all_not_understood(Module moduleScope) {
  exists(GlobalVariable allVar | 
    allVar.getId() = "__all__" and 
    allVar.getScope() = moduleScope and
    (
      // The module's __all__ is not defined as a simple list we understand
      not moduleScope.declaredInAll(_)
      or
      // The __all__ variable is modified (e.g., by appending)
      exists(Call modificationCall | 
        modificationCall.getFunc().(Attribute).getObject() = allVar.getALoad()
      )
    )
  )
}

// Checks if an imported module is used within a doctest string
predicate imported_module_used_in_doctest(Import importStmt) {
  exists(string moduleName, string docText |
    // Get the imported module name from the alias
    importStmt.getAName().getAsname().(Name).getId() = moduleName and
    // Retrieve the doctest string in the same scope
    docText = doctest_in_scope(importStmt.getScope()) and
    // Check if the doctest contains a reference to the module
    docText.regexpMatch("[\\s\\S]*(>>>|\\.\\.\\.).*" + moduleName + "[\\s\\S]*")
  )
}

// pragma[noinline]: Retrieves the doctest string within a given scope
pragma[noinline]
private string doctest_in_scope(Scope scope) {
  exists(StringLiteral docLiteral |
    // The docstring must be in the given scope
    docLiteral.getEnclosingModule() = scope and
    docLiteral.isDocString() and
    // The text of the docstring must contain doctest patterns
    result = docLiteral.getText() and
    result.regexpMatch("[\\s\\S]*(>>>|\\.\\.\\.)[\\s\\S]*")
  )
}

// pragma[noinline]: Extracts type hint annotations from a module
pragma[noinline]
private string typehint_annotation_in_module(Module moduleScope) {
  exists(StringLiteral typeAnnotation |
    // The annotation can come from various sources: arguments, annotated assignments, or function returns
    (
      typeAnnotation = any(Arguments args).getAnAnnotation().getASubExpression*()
      or
      typeAnnotation = any(AnnAssign annAssign).getAnnotation().getASubExpression*()
      or
      typeAnnotation = any(FunctionExpr func).getReturns().getASubExpression*()
    ) and
    // The annotation must point to a string value (for forward references)
    typeAnnotation.pointsTo(Value::forString(result)) and
    // The annotation must be in the given module
    typeAnnotation.getEnclosingModule() = moduleScope
  )
}

// pragma[noinline]: Retrieves type hint comments from a file
pragma[noinline]
private string typehint_comment_in_file(File file) {
  exists(Comment typeComment |
    // The comment must be in the given file
    file = typeComment.getLocation().getFile() and
    // The comment text must be a type hint comment
    result = typeComment.getText() and
    result.matches("# type:%")
  )
}

/** Holds if an imported alias is used in a type hint within the same file */
predicate imported_alias_used_in_typehint(Import importStmt, Variable name) {
  // The import's alias must refer to the given variable
  importStmt.getAName().getAsname().(Name).getVariable() = name and
  exists(File file, Module moduleScope |
    // Get the module and file from the import
    moduleScope = importStmt.getEnclosingModule() and
    file = moduleScope.getFile()
  |
    // Check if the alias is used in a type hint comment
    typehint_comment_in_file(file).regexpMatch("# type:.*" + name.getId() + ".*")
    or
    // Check if the alias is used in a string annotation (for forward references)
    typehint_annotation_in_module(moduleScope).regexpMatch(".*\\b" + name.getId() + "\\b.*")
  )
}

// Identifies an import that is not used in the code
predicate unused_import(Import importStmt, Variable name) {
  // The import must have an alias that refers to the given variable
  importStmt.getAName().getAsname().(Name).getVariable() = name and
  // Exclude __future__ imports as they are special
  not importStmt.getAnImportedModuleName() = "__future__" and
  // The import must be at the module level
  importStmt.getScope() = importStmt.getEnclosingModule() and
  // The imported name is not in the module's __all__ (if we understand it)
  not importStmt.getEnclosingModule().declaredInAll(name.getId()) and
  // The name is not used as a global variable
  not global_name_used(importStmt.getScope(), name.getId()) and
  // Exclude imports in __init__.py files (as they may be for package loading)
  not importStmt.getEnclosingModule().isPackageInit() and
  // The name is not referenced in epytext documentation comments
  not exists(Comment docComment | 
    docComment.getText().matches("%L{" + name.getId() + "}%") and
    docComment.getLocation().getFile() = importStmt.getLocation().getFile()
  ) and
  // The name is not one that is acceptable to be unused (e.g., _)
  not name_acceptable_for_unused_variable(name) and
  // The module does not have an __all__ that we don't understand (which might include the name)
  not all_not_understood(importStmt.getEnclosingModule()) and
  // The imported module is not used in doctests
  not imported_module_used_in_doctest(importStmt) and
  // The alias is not used in type hints
  not imported_alias_used_in_typehint(importStmt, name) and
  // The import is not a pytest fixture
  not is_pytest_fixture(importStmt, name) and
  // The import must actually point to something (i.e., it is not a failed import)
  importStmt.getAName().getValue().pointsTo(_)
}

// Query statement to identify unused imports
from Stmt s, Variable name
where unused_import(s, name)
select s, "Import of '" + name.getId() + "' is not used."