/**
 * @name Missing docstring
 * @description Public classes, functions or methods without documentation strings 
 *              reduce code maintainability by making it harder for other developers 
 *              to understand the code's purpose and usage.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/missing-docstring
 */

/*
 * Note: Medium precision due to the inherent subjectivity in determining when a 
 * docstring is required. The necessity often depends on the code's context and 
 * intended audience.
 */

import python

// Determines whether a scope requires documentation
predicate requires_documentation(Scope s) {
  s.isPublic() and
  (
    not s instanceof Function
    or
    function_needs_documentation(s)
  )
}

// Determines whether a function requires documentation
predicate function_needs_documentation(Function f) {
  f.getName() != "lambda" and
  (f.getMetrics().getNumberOfLinesOfCode() - count(f.getADecorator())) > 2 and
  not exists(PythonPropertyObject prop |
    prop.getGetter().getFunction() = f or
    prop.getSetter().getFunction() = f
  ) and
  not exists(FunctionValue override, FunctionValue base | 
    override.overrides(base) and override.getScope() = f |
    not function_needs_documentation(base.getScope())
  )
}

// Returns the type name of a scope (Module, Class, or Function)
string get_scope_type_name(Scope s) {
  result = "Module" and s instanceof Module and not s.(Module).isPackage()
  or
  result = "Class" and s instanceof Class
  or
  result = "Function" and s instanceof Function
}

// Identifies scopes that require documentation but lack it
from Scope s
where requires_documentation(s) and not exists(s.getDocString())
select s, get_scope_type_name(s) + " " + s.getName() + " does not have a docstring."