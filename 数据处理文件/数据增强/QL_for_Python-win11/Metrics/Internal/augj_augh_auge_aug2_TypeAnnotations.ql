/**
 * @name Type metrics
 * @description Provides statistics on different kinds of type annotations in Python code.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents Python's core built-in types: int, float, str, bool, bytes, None
class CoreType extends Name {
  CoreType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type representing three kinds of type-annotated elements:
// functions with return type annotations, parameters with type annotations, and annotated assignments
newtype TTypeAnnotated =
  TFuncWithReturn(FunctionExpr func) { exists(func.getReturns()) } or
  TParamWithAnnotation(Parameter param) { exists(param.getAnnotation()) } or
  TAssignWithAnnotation(AnnAssign assign) { exists(assign.getAnnotation()) }

// Abstract class representing elements that have type annotations
abstract class TypeAnnotated extends TTypeAnnotated {
  string toString() { result = "TypeAnnotated" }
  abstract Expr getAnnotation();
}

// Represents a function expression that has a return type annotation
class FuncWithReturn extends TFuncWithReturn, TypeAnnotated {
  FunctionExpr funcExpr;

  FuncWithReturn() { this = TFuncWithReturn(funcExpr) }
  override Expr getAnnotation() { result = funcExpr.getReturns() }
}

// Represents a parameter that has a type annotation
class ParamWithAnnotation extends TParamWithAnnotation, TypeAnnotated {
  Parameter param;

  ParamWithAnnotation() { this = TParamWithAnnotation(param) }
  override Expr getAnnotation() { result = param.getAnnotation() }
}

// Represents an annotated assignment statement
class AssignWithAnnotation extends TAssignWithAnnotation, TypeAnnotated {
  AnnAssign annotAssign;

  AssignWithAnnotation() { this = TAssignWithAnnotation(annotAssign) }
  override Expr getAnnotation() { result = annotAssign.getAnnotation() }
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
  overall = count(ParamWithAnnotation paramAnnot) and 
  core_count = count(ParamWithAnnotation paramAnnot | is_core_type(paramAnnot.getAnnotation())) and 
  forward_count = count(ParamWithAnnotation paramAnnot | is_forward_decl(paramAnnot.getAnnotation())) and 
  basic_count = count(ParamWithAnnotation paramAnnot | is_basic_type(paramAnnot.getAnnotation())) and 
  complicated_count = count(ParamWithAnnotation paramAnnot | is_complicated_type(paramAnnot.getAnnotation())) and 
  optional_count = count(ParamWithAnnotation paramAnnot | is_optional(paramAnnot.getAnnotation()))
  or
  // Metrics for return type annotations
  category = "Return type annotation" and 
  overall = count(FuncWithReturn funcAnnot) and 
  core_count = count(FuncWithReturn funcAnnot | is_core_type(funcAnnot.getAnnotation())) and 
  forward_count = count(FuncWithReturn funcAnnot | is_forward_decl(funcAnnot.getAnnotation())) and 
  basic_count = count(FuncWithReturn funcAnnot | is_basic_type(funcAnnot.getAnnotation())) and 
  complicated_count = count(FuncWithReturn funcAnnot | is_complicated_type(funcAnnot.getAnnotation())) and 
  optional_count = count(FuncWithReturn funcAnnot | is_optional(funcAnnot.getAnnotation()))
  or
  // Metrics for annotated assignments
  category = "Annotated assignment" and 
  overall = count(AssignWithAnnotation assignAnnot) and 
  core_count = count(AssignWithAnnotation assignAnnot | is_core_type(assignAnnot.getAnnotation())) and 
  forward_count = count(AssignWithAnnotation assignAnnot | is_forward_decl(assignAnnot.getAnnotation())) and 
  basic_count = count(AssignWithAnnotation assignAnnot | is_basic_type(assignAnnot.getAnnotation())) and 
  complicated_count = count(AssignWithAnnotation assignAnnot | is_complicated_type(assignAnnot.getAnnotation())) and 
  optional_count = count(AssignWithAnnotation assignAnnot | is_optional(assignAnnot.getAnnotation()))
}

// Query to retrieve annotation metrics
from
  string category, int overall, int core, int forward, int basic, int complicated, int optional
where annotation_metrics(category, overall, core, forward, basic, complicated, optional)
select category, overall, core, forward, basic, complicated, optional