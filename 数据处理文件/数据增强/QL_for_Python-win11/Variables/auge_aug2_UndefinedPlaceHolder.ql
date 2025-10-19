/**
 * @name Use of an undefined placeholder variable
 * @description Identifies placeholder variables that are referenced without proper initialization, potentially leading to runtime exceptions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/undefined-placeholder-variable
 */

import python
import Variables.MonkeyPatched

// Determine if the placeholder reference is properly initialized within the local function scope
predicate is_locally_initialized(PlaceHolder placeholder_ref) {
  exists(SsaVariable ssa_definition, Function enclosing_function | 
    enclosing_function = placeholder_ref.getScope() and 
    ssa_definition.getAUse() = placeholder_ref.getAFlowNode() |
    ssa_definition.getVariable() instanceof LocalVariable and
    not ssa_definition.maybeUndefined()
  )
}

// Retrieve the class that contains the placeholder reference
Class get_enclosing_class(PlaceHolder placeholder_ref) { 
  result.getAMethod() = placeholder_ref.getScope() 
}

// Check if the placeholder is defined as an attribute within the class context
predicate is_template_attribute(PlaceHolder placeholder_ref) {
  exists(ImportTimeScope class_context | 
    class_context = get_enclosing_class(placeholder_ref) | 
    class_context.definesName(placeholder_ref.getId())
  )
}

// Verify that the placeholder is not a global variable, module attribute, or monkey-patched builtin
predicate is_not_global_variable(PlaceHolder placeholder_ref) {
  // Exclude module-level attributes, globally defined names, and monkey-patched builtins
  not exists(PythonModuleObject python_module |
    python_module.hasAttribute(placeholder_ref.getId()) and 
    python_module.getModule() = placeholder_ref.getEnclosingModule()
  ) and
  not globallyDefinedName(placeholder_ref.getId()) and
  not monkey_patched_builtin(placeholder_ref.getId())
}

// Main query: Identify placeholder variables that may be used without proper initialization
from PlaceHolder undefined_placeholder
where
  not is_locally_initialized(undefined_placeholder) and
  not is_template_attribute(undefined_placeholder) and
  is_not_global_variable(undefined_placeholder)
select undefined_placeholder, "This use of place-holder variable '" + undefined_placeholder.getId() + "' may be undefined."