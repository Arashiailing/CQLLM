/**
 * @name Type metrics
 * @description Provides statistics on different kinds of type annotations in Python code.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents built-in types in Python.
class CoreType extends Name {
  // Constructor that checks if the current instance is one of the core types.
  CoreType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Defines a new type TTypeAnnotated that can be one of three cases:
newtype TTypeAnnotated =
  TFuncWithReturn(FunctionExpr function) { exists(function.getReturns()) } or // Function expressions with return type
  TParamWithAnnotation(Parameter parameter) { exists(parameter.getAnnotation()) } or // Parameters with annotations
  TAssignWithAnnotation(AnnAssign assignment) { exists(assignment.getAnnotation()) } // Assignment statements with annotations

// Abstract class TypeAnnotated, inheriting from TTypeAnnotated, representing elements that can have type annotations.
abstract class TypeAnnotated extends TTypeAnnotated {
  // Converts the object to its string representation.
  string toString() { result = "TypeAnnotated" }

  // Abstract method to get the annotation expression.
  abstract Expr getAnnotation();
}

// Class FuncWithReturn, inheriting from TFuncWithReturn and TypeAnnotated, representing functions with return type annotations.
class FuncWithReturn extends TFuncWithReturn, TypeAnnotated {
  FunctionExpr function; // Function expression

  // Constructor that initializes the function attribute.
  FuncWithReturn() { this = TFuncWithReturn(function) }

  // Overrides getAnnotation method to return the function's return type annotation.
  override Expr getAnnotation() { result = function.getReturns() }
}

// Class ParamWithAnnotation, inheriting from TParamWithAnnotation and TypeAnnotated, representing parameters with annotations.
class ParamWithAnnotation extends TParamWithAnnotation, TypeAnnotated {
  Parameter parameter; // Parameter

  // Constructor that initializes the parameter attribute.
  ParamWithAnnotation() { this = TParamWithAnnotation(parameter) }

  // Overrides getAnnotation method to return the parameter's annotation.
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Class AssignWithAnnotation, inheriting from TAssignWithAnnotation and TypeAnnotated, representing assignment statements with annotations.
class AssignWithAnnotation extends TAssignWithAnnotation, TypeAnnotated {
  AnnAssign assignment; // Assignment statement

  // Constructor that initializes the assignment attribute.
  AssignWithAnnotation() { this = TAssignWithAnnotation(assignment) }

  // Overrides getAnnotation method to return the assignment's annotation.
  override Expr getAnnotation() { result = assignment.getAnnotation() }
}

/** True if `expr` is a string literal used as a forward declaration of a type. */
predicate is_forward_decl(Expr expr) { expr instanceof StringLiteral }

/** True if `expr` represents a type that is complex to analyze. */
predicate is_complicated_type(Expr expr) {
  expr instanceof Subscript and not is_optional(expr) // If expr is a subscript but not an optional type
  or
  expr instanceof Tuple // If expr is a tuple type
  or
  expr instanceof List // If expr is a list type
}

/** True if `expr` is a type of the form `Optional[...]`. */
predicate is_optional(Subscript expr) { expr.getObject().(Name).getId() = "Optional" }

/** True if `expr` is a simple type, i.e., an identifier (excluding core types) or an attribute of a simple type. */
predicate is_basic_type(Expr expr) {
  expr instanceof Name and not expr instanceof CoreType // If expr is a name but not a core type
  or
  is_basic_type(expr.(Attribute).getObject()) // If expr is an attribute and its object is a basic type
}

/** True if `expr` is a core type. */
predicate is_core_type(Expr expr) { expr instanceof CoreType }

// Predicate to calculate counts of different types of annotations.
predicate annotation_metrics(
  string category, int overall, int core_count, int forward_count, int basic_count,
  int complicated_count, int optional_count
) {
  // For parameter annotations
  category = "Parameter annotation" and 
  overall = count(ParamWithAnnotation annotatedParam) and 
  core_count = count(ParamWithAnnotation annotatedParam | is_core_type(annotatedParam.getAnnotation())) and 
  forward_count = count(ParamWithAnnotation annotatedParam | is_forward_decl(annotatedParam.getAnnotation())) and 
  basic_count = count(ParamWithAnnotation annotatedParam | is_basic_type(annotatedParam.getAnnotation())) and 
  complicated_count = count(ParamWithAnnotation annotatedParam | is_complicated_type(annotatedParam.getAnnotation())) and 
  optional_count = count(ParamWithAnnotation annotatedParam | is_optional(annotatedParam.getAnnotation()))
  or
  // For return type annotations
  category = "Return type annotation" and 
  overall = count(FuncWithReturn annotatedFunc) and 
  core_count = count(FuncWithReturn annotatedFunc | is_core_type(annotatedFunc.getAnnotation())) and 
  forward_count = count(FuncWithReturn annotatedFunc | is_forward_decl(annotatedFunc.getAnnotation())) and 
  basic_count = count(FuncWithReturn annotatedFunc | is_basic_type(annotatedFunc.getAnnotation())) and 
  complicated_count = count(FuncWithReturn annotatedFunc | is_complicated_type(annotatedFunc.getAnnotation())) and 
  optional_count = count(FuncWithReturn annotatedFunc | is_optional(annotatedFunc.getAnnotation()))
  or
  // For annotated assignments
  category = "Annotated assignment" and 
  overall = count(AssignWithAnnotation annotatedAssign) and 
  core_count = count(AssignWithAnnotation annotatedAssign | is_core_type(annotatedAssign.getAnnotation())) and 
  forward_count = count(AssignWithAnnotation annotatedAssign | is_forward_decl(annotatedAssign.getAnnotation())) and 
  basic_count = count(AssignWithAnnotation annotatedAssign | is_basic_type(annotatedAssign.getAnnotation())) and 
  complicated_count = count(AssignWithAnnotation annotatedAssign | is_complicated_type(annotatedAssign.getAnnotation())) and 
  optional_count = count(AssignWithAnnotation annotatedAssign | is_optional(annotatedAssign.getAnnotation()))
}

// Query statement to select data from the database that satisfies the annotation_metrics predicate.
from
  string category, int overall, int core, int forward, int basic, int complicated, int optional
where annotation_metrics(category, overall, core, forward, basic, complicated, optional)
select category, overall, core, forward, basic, complicated, optional