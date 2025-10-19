/**
 * @name Type metrics
 * @description Provides statistics on different kinds of type annotations in Python code.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents Python's built-in types: int, float, str, bool, bytes, None
class CoreType extends Name {
  CoreType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type representing three kinds of type-annotated elements:
// functions with return type annotations, parameters with type annotations, and annotated assignments
newtype TTypeAnnotated =
  TFuncWithReturn(FunctionExpr function) { exists(function.getReturns()) } or
  TParamWithAnnotation(Parameter parameter) { exists(parameter.getAnnotation()) } or
  TAssignWithAnnotation(AnnAssign assignment) { exists(assignment.getAnnotation()) }

// Abstract class representing elements that have type annotations
abstract class TypeAnnotated extends TTypeAnnotated {
  string toString() { result = "TypeAnnotated" }
  abstract Expr getAnnotation();
}

// Represents a function expression that has a return type annotation
class FuncWithReturn extends TFuncWithReturn, TypeAnnotated {
  FunctionExpr functionExpr;

  FuncWithReturn() { this = TFuncWithReturn(functionExpr) }
  override Expr getAnnotation() { result = functionExpr.getReturns() }
}

// Represents a parameter that has a type annotation
class ParamWithAnnotation extends TParamWithAnnotation, TypeAnnotated {
  Parameter parameter;

  ParamWithAnnotation() { this = TParamWithAnnotation(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Represents an annotated assignment statement
class AssignWithAnnotation extends TAssignWithAnnotation, TypeAnnotated {
  AnnAssign annotatedAssignment;

  AssignWithAnnotation() { this = TAssignWithAnnotation(annotatedAssignment) }
  override Expr getAnnotation() { result = annotatedAssignment.getAnnotation() }
}

// Holds if the given expression is a string literal used as a forward reference for a type
predicate is_forward_decl(Expr expr) { expr instanceof StringLiteral }

// Holds if the given expression represents a complex type structure
predicate is_complicated_type(Expr expr) {
  expr instanceof Subscript and not is_optional(expr) or
  expr instanceof Tuple or
  expr instanceof List
}

// Holds if the given expression is an Optional type annotation
predicate is_optional(Subscript expr) { expr.getObject().(Name).getId() = "Optional" }

// Holds if the given expression is a basic type (non-core identifier or attribute chain)
predicate is_basic_type(Expr expr) {
  expr instanceof Name and not expr instanceof CoreType or
  is_basic_type(expr.(Attribute).getObject())
}

// Holds if the given expression is a core built-in type
predicate is_core_type(Expr expr) { expr instanceof CoreType }

// Calculates metrics for different categories of type annotations
predicate annotation_metrics(
  string category, int overall, int core_count, int forward_count, int basic_count,
  int complicated_count, int optional_count
) {
  // Metrics for parameter annotations
  category = "Parameter annotation" and 
  overall = count(ParamWithAnnotation paramAnnotation) and 
  core_count = count(ParamWithAnnotation paramAnnotation | is_core_type(paramAnnotation.getAnnotation())) and 
  forward_count = count(ParamWithAnnotation paramAnnotation | is_forward_decl(paramAnnotation.getAnnotation())) and 
  basic_count = count(ParamWithAnnotation paramAnnotation | is_basic_type(paramAnnotation.getAnnotation())) and 
  complicated_count = count(ParamWithAnnotation paramAnnotation | is_complicated_type(paramAnnotation.getAnnotation())) and 
  optional_count = count(ParamWithAnnotation paramAnnotation | is_optional(paramAnnotation.getAnnotation()))
  or
  // Metrics for return type annotations
  category = "Return type annotation" and 
  overall = count(FuncWithReturn funcAnnotation) and 
  core_count = count(FuncWithReturn funcAnnotation | is_core_type(funcAnnotation.getAnnotation())) and 
  forward_count = count(FuncWithReturn funcAnnotation | is_forward_decl(funcAnnotation.getAnnotation())) and 
  basic_count = count(FuncWithReturn funcAnnotation | is_basic_type(funcAnnotation.getAnnotation())) and 
  complicated_count = count(FuncWithReturn funcAnnotation | is_complicated_type(funcAnnotation.getAnnotation())) and 
  optional_count = count(FuncWithReturn funcAnnotation | is_optional(funcAnnotation.getAnnotation()))
  or
  // Metrics for annotated assignments
  category = "Annotated assignment" and 
  overall = count(AssignWithAnnotation assignAnnotation) and 
  core_count = count(AssignWithAnnotation assignAnnotation | is_core_type(assignAnnotation.getAnnotation())) and 
  forward_count = count(AssignWithAnnotation assignAnnotation | is_forward_decl(assignAnnotation.getAnnotation())) and 
  basic_count = count(AssignWithAnnotation assignAnnotation | is_basic_type(assignAnnotation.getAnnotation())) and 
  complicated_count = count(AssignWithAnnotation assignAnnotation | is_complicated_type(assignAnnotation.getAnnotation())) and 
  optional_count = count(AssignWithAnnotation assignAnnotation | is_optional(assignAnnotation.getAnnotation()))
}

// Query to retrieve annotation metrics
from
  string category, int overall, int core, int forward, int basic, int complicated, int optional
where annotation_metrics(category, overall, core, forward, basic, complicated, optional)
select category, overall, core, forward, basic, complicated, optional