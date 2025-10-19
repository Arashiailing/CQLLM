/**
 * @name Type metrics
 * @description Provides statistics on different kinds of type annotations in Python code.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents fundamental built-in types in Python.
class CoreType extends Name {
  // Constructor that identifies core types by their names.
  CoreType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Defines a new type TTypeAnnotated representing three annotation scenarios:
newtype TTypeAnnotated =
  TFuncWithReturn(FunctionExpr functionExpr) { exists(functionExpr.getReturns()) } or // Functions with return type annotations
  TParamWithAnnotation(Parameter parameter) { exists(parameter.getAnnotation()) } or // Parameters with type annotations
  TAssignWithAnnotation(AnnAssign annotatedAssignment) { exists(annotatedAssignment.getAnnotation()) } // Annotated assignments

// Abstract class TypeAnnotated representing elements with type annotations.
abstract class TypeAnnotated extends TTypeAnnotated {
  // Converts the object to its string representation.
  string toString() { result = "TypeAnnotated" }

  // Abstract method to retrieve the annotation expression.
  abstract Expr getAnnotation();
}

// Class representing functions with return type annotations.
class FuncWithReturn extends TFuncWithReturn, TypeAnnotated {
  FunctionExpr functionExpr; // Associated function expression

  // Constructor linking the function expression.
  FuncWithReturn() { this = TFuncWithReturn(functionExpr) }

  // Returns the function's return type annotation.
  override Expr getAnnotation() { result = functionExpr.getReturns() }
}

// Class representing parameters with type annotations.
class ParamWithAnnotation extends TParamWithAnnotation, TypeAnnotated {
  Parameter parameter; // Associated parameter

  // Constructor linking the parameter.
  ParamWithAnnotation() { this = TParamWithAnnotation(parameter) }

  // Returns the parameter's type annotation.
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Class representing annotated assignments.
class AssignWithAnnotation extends TAssignWithAnnotation, TypeAnnotated {
  AnnAssign annotatedAssignment; // Associated assignment

  // Constructor linking the assignment.
  AssignWithAnnotation() { this = TAssignWithAnnotation(annotatedAssignment) }

  // Returns the assignment's type annotation.
  override Expr getAnnotation() { result = annotatedAssignment.getAnnotation() }
}

/** Determines if an expression is a string literal used for forward type declarations. */
predicate is_forward_decl(Expr expr) { expr instanceof StringLiteral }

/** Identifies complex type expressions that require deeper analysis. */
predicate is_complicated_type(Expr expr) {
  expr instanceof Subscript and not is_optional(expr) // Non-optional subscript types
  or
  expr instanceof Tuple // Tuple type annotations
  or
  expr instanceof List // List type annotations
}

/** Checks if a subscript represents an Optional type. */
predicate is_optional(Subscript subscriptExpr) { subscriptExpr.getObject().(Name).getId() = "Optional" }

/** Identifies basic types (identifiers excluding core types or attributes of basic types). */
predicate is_basic_type(Expr expr) {
  expr instanceof Name and not expr instanceof CoreType // Non-core name types
  or
  is_basic_type(expr.(Attribute).getObject()) // Attributes of basic types
}

/** Checks if an expression represents a core type. */
predicate is_core_type(Expr expr) { expr instanceof CoreType }

// Computes metrics for different annotation categories.
predicate annotation_metrics(
  string category, int overall, int core_count, int forward_count, int basic_count,
  int complicated_count, int optional_count
) {
  // Parameter annotation metrics
  category = "Parameter annotation" and 
  overall = count(ParamWithAnnotation paramAnnotation) and 
  core_count = count(ParamWithAnnotation paramAnnotation | is_core_type(paramAnnotation.getAnnotation())) and 
  forward_count = count(ParamWithAnnotation paramAnnotation | is_forward_decl(paramAnnotation.getAnnotation())) and 
  basic_count = count(ParamWithAnnotation paramAnnotation | is_basic_type(paramAnnotation.getAnnotation())) and 
  complicated_count = count(ParamWithAnnotation paramAnnotation | is_complicated_type(paramAnnotation.getAnnotation())) and 
  optional_count = count(ParamWithAnnotation paramAnnotation | is_optional(paramAnnotation.getAnnotation()))
  or
  // Return type annotation metrics
  category = "Return type annotation" and 
  overall = count(FuncWithReturn funcAnnotation) and 
  core_count = count(FuncWithReturn funcAnnotation | is_core_type(funcAnnotation.getAnnotation())) and 
  forward_count = count(FuncWithReturn funcAnnotation | is_forward_decl(funcAnnotation.getAnnotation())) and 
  basic_count = count(FuncWithReturn funcAnnotation | is_basic_type(funcAnnotation.getAnnotation())) and 
  complicated_count = count(FuncWithReturn funcAnnotation | is_complicated_type(funcAnnotation.getAnnotation())) and 
  optional_count = count(FuncWithReturn funcAnnotation | is_optional(funcAnnotation.getAnnotation()))
  or
  // Annotated assignment metrics
  category = "Annotated assignment" and 
  overall = count(AssignWithAnnotation assignAnnotation) and 
  core_count = count(AssignWithAnnotation assignAnnotation | is_core_type(assignAnnotation.getAnnotation())) and 
  forward_count = count(AssignWithAnnotation assignAnnotation | is_forward_decl(assignAnnotation.getAnnotation())) and 
  basic_count = count(AssignWithAnnotation assignAnnotation | is_basic_type(assignAnnotation.getAnnotation())) and 
  complicated_count = count(AssignWithAnnotation assignAnnotation | is_complicated_type(assignAnnotation.getAnnotation())) and 
  optional_count = count(AssignWithAnnotation assignAnnotation | is_optional(assignAnnotation.getAnnotation()))
}

// Query to retrieve annotation metrics for all categories.
from
  string category, int overall, int core, int forward, int basic, int complicated, int optional
where annotation_metrics(category, overall, core, forward, basic, complicated, optional)
select category, overall, core, forward, basic, complicated, optional