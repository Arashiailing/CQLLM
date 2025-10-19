/**
 * @name Use of an undefined global variable
 * @description Detects usage of global variables before they are initialized, which can cause runtime exceptions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision low
 * @id py/undefined-global-variable
 */

import python
import Variables.MonkeyPatched
import semmle.python.pointsto.PointsTo

/**
 * Determines if a variable access is protected against NameError exceptions
 * by specific error handling mechanisms such as try-except blocks or
 * conditional checks with globals().
 */
predicate is_name_error_guarded(Name varAccess) {
  // Protection via try-except block catching NameError
  exists(Try tryBlock | tryBlock.getBody().getAnItem().contains(varAccess) |
    tryBlock.getAHandler().getType().(Name).getId() = "NameError"
  )
  or
  // Protection via conditional block controlling globals() check
  exists(ConditionBlock guardCondition, BasicBlock dependentBlock, Call globalsCall |
    (guardCondition.getLastNode().getNode().contains(globalsCall) or
     guardCondition.getLastNode().getNode() = globalsCall) and
    globalsCall.getFunc().(Name).getId() = "globals" and
    guardCondition.controls(dependentBlock, _) and
    dependentBlock.contains(varAccess.getAFlowNode())
  )
}

/**
 * Checks if a module contains unresolved star imports (from module import *)
 * that could potentially define the variable being accessed.
 */
predicate has_unresolved_star_import(Module targetModule) {
  exists(ImportStar starImport | starImport.getScope() = targetModule |
    exists(ModuleValue sourceModule | 
      sourceModule.importedAs(starImport.getImportedModuleName()) and
      not sourceModule.hasCompleteExportInfo()
    )
  )
}

/**
 * Checks if a module uses dynamic execution functions (exec, execfile)
 * that could potentially define variables at runtime, making static analysis unreliable.
 */
predicate uses_dynamic_execution(Module targetModule) {
  exists(Exec execStmt | execStmt.getScope() = targetModule)
  or
  exists(CallNode dynamicCall, FunctionValue execFunc | 
    execFunc.getACall() = dynamicCall and dynamicCall.getScope() = targetModule and
    (execFunc.getName() = "exec" or execFunc.getName() = "execfile")
  )
}

/**
 * Helper predicate to determine if a name is defined at module level,
 * in builtins, or as a special attribute like __path__ in package init files.
 */
private predicate is_module_level_or_builtin_defined(Name varAccess) {
  varAccess.getEnclosingModule().(ImportTimeScope).definesName(varAccess.getId()) or
  exists(ModuleValue moduleEntity | moduleEntity.getScope() = varAccess.getEnclosingModule() | 
    moduleEntity.hasAttribute(varAccess.getId())) or
  globallyDefinedName(varAccess.getId()) or
  (varAccess.getEnclosingModule().isPackageInit() and varAccess.getId() = "__path__")
}

/**
 * Checks if this is the first occurrence of a variable usage in a basic block.
 * This helps identify the earliest point where an undefined variable is used.
 */
private predicate is_first_usage_in_block(Name varAccess) {
  exists(GlobalVariable globalVar, BasicBlock codeBlock, int positionIndex |
    positionIndex = min(int index | codeBlock.getNode(index).getNode() = globalVar.getALoad()) and 
    codeBlock.getNode(positionIndex) = varAccess.getAFlowNode()
  )
}

/**
 * Checks for undefined global variable usage within function scope.
 * This predicate identifies cases where a global variable is used inside a function
 * without being properly defined as global or at module level.
 */
predicate is_undefined_in_function_context(Name varAccess) {
  exists(Function enclosingFunction, GlobalVariable globalVar |
    varAccess.getScope().getScope*() = enclosingFunction and
    varAccess.uses(globalVar) and
    // Verify function is method/nested or module-initialized
    (
      not enclosingFunction.getScope() = varAccess.getEnclosingModule() or
      varAccess.getEnclosingModule().(ImportTimeScope).definesName(enclosingFunction.getName())
    ) and
    // Check that the global variable is not defined in the function or its enclosing scopes (except module)
    not exists(Assign varAssignment, Scope definingScope |
      varAssignment.getATarget() = globalVar.getAnAccess() and varAssignment.getScope() = definingScope and
      (definingScope = enclosingFunction or
       (definingScope = enclosingFunction.getScope().getScope*() and 
        not definingScope instanceof Module))
    ) and
    // Ensure no module-level definition
    not is_module_level_or_builtin_defined(varAccess) and
    not exists(SsaVariable ssaVar | ssaVar.getAUse().getNode() = varAccess and 
      not ssaVar.maybeUndefined()) and
    not is_name_error_guarded(varAccess)
  )
}

/**
 * Checks for undefined global variable usage within class or module scope.
 * This predicate identifies cases where a variable is used at the class or module level
 * without being properly defined.
 */
predicate is_undefined_in_class_or_module(Name varAccess) {
  exists(GlobalVariable globalVar | varAccess.uses(globalVar)) and
  not varAccess.getScope().getScope*() instanceof Function and
  exists(SsaVariable ssaVar | ssaVar.getAUse().getNode() = varAccess and 
    ssaVar.maybeUndefined()) and
  not is_name_error_guarded(varAccess) and
  not is_module_level_or_builtin_defined(varAccess)
}

/**
 * Main predicate for undefined global variable usage.
 * Combines context checks with various exclusions to identify cases where
 * a global variable is used without being properly defined.
 */
predicate is_undefined_global_usage(Name varAccess) {
  // Combine context checks with exclusions
  (
    is_undefined_in_class_or_module(varAccess)
    or
    is_undefined_in_function_context(varAccess)
  ) and
  // Apply exclusions
  not monkey_patched_builtin(varAccess.getId()) and
  not has_unresolved_star_import(varAccess.getEnclosingModule()) and
  not uses_dynamic_execution(varAccess.getEnclosingModule()) and
  not exists(varAccess.getVariable().getAStore()) and
  not varAccess.pointsTo(_)
}

/**
 * Identifies the first undefined usage of a global variable in control flow.
 * This helps focus on the most relevant instances of undefined variable usage.
 */
predicate is_first_undefined_usage(Name varAccess) {
  is_undefined_global_usage(varAccess) and
  exists(GlobalVariable globalVar | globalVar.getALoad() = varAccess |
    is_first_usage_in_block(varAccess) and
    not exists(ControlFlowNode precedingNode |
      precedingNode.getNode() = globalVar.getALoad() and
      precedingNode.getBasicBlock().strictlyDominates(varAccess.getAFlowNode().getBasicBlock())
    )
  )
}

// Query: Find first undefined global variable usages
from Name variableAccess
where is_first_undefined_usage(variableAccess)
select variableAccess, "This use of global variable '" + variableAccess.getId() + "' may be undefined."