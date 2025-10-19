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
  TFuncWithReturn(FunctionExpr f) { exists(f.getReturns()) } or // Function expressions with return type
  TParamWithAnnotation(Parameter p) { exists(p.getAnnotation()) } or // Parameters with annotations
  TAssignWithAnnotation(AnnAssign a) { exists(a.getAnnotation()) } // Assignment statements with annotations

// Abstract class TypeAnnotated, inheriting from TTypeAnnotated, representing elements that can have type annotations.
abstract class TypeAnnotated extends TTypeAnnotated {
  // Converts the object to its string representation.
  string toString() { result = "TypeAnnotated" }

  // Abstract method to get the annotation expression.
  abstract Expr getAnnotation();
}

// Class FuncWithReturn, inheriting from TFuncWithReturn and TypeAnnotated, representing functions with return type annotations.
class FuncWithReturn extends TFuncWithReturn, TypeAnnotated {
  FunctionExpr func; // Function expression

  // Constructor that initializes the func attribute.
  FuncWithReturn() { this = TFuncWithReturn(func) }

  // Overrides getAnnotation method to return the function's return type annotation.
  override Expr getAnnotation() { result = func.getReturns() }
}

// Class ParamWithAnnotation, inheriting from TParamWithAnnotation and TypeAnnotated, representing parameters with annotations.
class ParamWithAnnotation extends TParamWithAnnotation, TypeAnnotated {
  Parameter param; // Parameter

  // Constructor that initializes the param attribute.
  ParamWithAnnotation() { this = TParamWithAnnotation(param) }

  // Overrides getAnnotation method to return the parameter's annotation.
  override Expr getAnnotation() { result = param.getAnnotation() }
}

// Class AssignWithAnnotation, inheriting from TAssignWithAnnotation and TypeAnnotated, representing assignment statements with annotations.
class AssignWithAnnotation extends TAssignWithAnnotation, TypeAnnotated {
  AnnAssign assign; // Assignment statement

  // Constructor that initializes the assign attribute.
  AssignWithAnnotation() { this = TAssignWithAnnotation(assign) }

  // Overrides getAnnotation method to return the assignment's annotation.
  override Expr getAnnotation() { result = assign.getAnnotation() }
}

/** True if `e` is a string literal used as a forward declaration of a type. */
predicate is_forward_decl(Expr e) { e instanceof StringLiteral }

/** True if `e` represents a type that is complex to analyze. */
predicate is_complicated_type(Expr e) {
  e instanceof Subscript and not is_optional(e) // If e is a subscript but not an optional type
  or
  e instanceof Tuple // If e is a tuple type
  or
  e instanceof List // If e is a list type
}

/** True if `e` is a type of the form `Optional[...]`. */
predicate is_optional(Subscript e) { e.getObject().(Name).getId() = "Optional" }

/** True if `e` is a simple type, i.e., an identifier (excluding core types) or an attribute of a simple type. */
predicate is_basic_type(Expr e) {
  e instanceof Name and not e instanceof CoreType // If e is a name but not a core type
  or
  is_basic_type(e.(Attribute).getObject()) // If e is an attribute and its object is a basic type
}

/** True if `e` is a core type. */
predicate is_core_type(Expr e) { e instanceof CoreType }

// Predicate to calculate counts of different types of annotations.
predicate annotation_metrics(
  string category, int overall, int core_count, int forward_count, int basic_count,
  int complicated_count, int optional_count
) {
  // For parameter annotations
  category = "Parameter annotation" and 
  overall = count(ParamWithAnnotation p) and 
  core_count = count(ParamWithAnnotation p | is_core_type(p.getAnnotation())) and 
  forward_count = count(ParamWithAnnotation p | is_forward_decl(p.getAnnotation())) and 
  basic_count = count(ParamWithAnnotation p | is_basic_type(p.getAnnotation())) and 
  complicated_count = count(ParamWithAnnotation p | is_complicated_type(p.getAnnotation())) and 
  optional_count = count(ParamWithAnnotation p | is_optional(p.getAnnotation()))
  or
  // For return type annotations
  category = "Return type annotation" and 
  overall = count(FuncWithReturn f) and 
  core_count = count(FuncWithReturn f | is_core_type(f.getAnnotation())) and 
  forward_count = count(FuncWithReturn f | is_forward_decl(f.getAnnotation())) and 
  basic_count = count(FuncWithReturn f | is_basic_type(f.getAnnotation())) and 
  complicated_count = count(FuncWithReturn f | is_complicated_type(f.getAnnotation())) and 
  optional_count = count(FuncWithReturn f | is_optional(f.getAnnotation()))
  or
  // For annotated assignments
  category = "Annotated assignment" and 
  overall = count(AssignWithAnnotation a) and 
  core_count = count(AssignWithAnnotation a | is_core_type(a.getAnnotation())) and 
  forward_count = count(AssignWithAnnotation a | is_forward_decl(a.getAnnotation())) and 
  basic_count = count(AssignWithAnnotation a | is_basic_type(a.getAnnotation())) and 
  complicated_count = count(AssignWithAnnotation a | is_complicated_type(a.getAnnotation())) and 
  optional_count = count(AssignWithAnnotation a | is_optional(a.getAnnotation()))
}

// Query statement to select data from the database that satisfies the annotation_metrics predicate.
from
  string category, int overall, int core, int forward, int basic, int complicated, int optional
where annotation_metrics(category, overall, core, forward, basic, complicated, optional)
select category, overall, core, forward, basic, complicated, optional