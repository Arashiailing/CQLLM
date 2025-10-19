/**
 * @name Type metrics
 * @description Provides statistics on different kinds of type annotations in Python code.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents built-in types in Python.
class BuiltinType extends Name {
  // Constructor that checks if the current instance is one of the core types.
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Defines a new type TTypedElement that can be one of three cases:
newtype TTypedElement =
  TFunctionWithReturn(FunctionExpr f) { exists(f.getReturns()) } or // Function expressions with return type
  TAnnotatedParameter(Parameter p) { exists(p.getAnnotation()) } or // Parameters with annotations
  TAnnotatedAssignment(AnnAssign a) { exists(a.getAnnotation()) } // Assignment statements with annotations

// Abstract class TypedElement, inheriting from TTypedElement, representing elements that can have type annotations.
abstract class TypedElement extends TTypedElement {
  // Converts the object to its string representation.
  string toString() { result = "TypedElement" }

  // Abstract method to get the annotation expression.
  abstract Expr getAnnotation();
}

// Class FunctionWithReturn, inheriting from TFunctionWithReturn and TypedElement, representing functions with return type annotations.
class FunctionWithReturn extends TFunctionWithReturn, TypedElement {
  FunctionExpr funcExpr; // Function expression

  // Constructor that initializes the funcExpr attribute.
  FunctionWithReturn() { this = TFunctionWithReturn(funcExpr) }

  // Overrides getAnnotation method to return the function's return type annotation.
  override Expr getAnnotation() { result = funcExpr.getReturns() }
}

// Class AnnotatedParameter, inheriting from TAnnotatedParameter and TypedElement, representing parameters with annotations.
class AnnotatedParameter extends TAnnotatedParameter, TypedElement {
  Parameter param; // Parameter

  // Constructor that initializes the param attribute.
  AnnotatedParameter() { this = TAnnotatedParameter(param) }

  // Overrides getAnnotation method to return the parameter's annotation.
  override Expr getAnnotation() { result = param.getAnnotation() }
}

// Class AnnotatedAssignment, inheriting from TAnnotatedAssignment and TypedElement, representing assignment statements with annotations.
class AnnotatedAssignment extends TAnnotatedAssignment, TypedElement {
  AnnAssign annAssign; // Assignment statement

  // Constructor that initializes the annAssign attribute.
  AnnotatedAssignment() { this = TAnnotatedAssignment(annAssign) }

  // Overrides getAnnotation method to return the assignment's annotation.
  override Expr getAnnotation() { result = annAssign.getAnnotation() }
}

/** True if `expr` is a string literal used as a forward declaration of a type. */
predicate isForwardDeclaration(Expr expr) { expr instanceof StringLiteral }

/** True if `expr` represents a type that is complex to analyze. */
predicate isComplexType(Expr expr) {
  expr instanceof Subscript and not isOptionalType(expr) // If expr is a subscript but not an optional type
  or
  expr instanceof Tuple // If expr is a tuple type
  or
  expr instanceof List // If expr is a list type
}

/** True if `expr` is a type of the form `Optional[...]`. */
predicate isOptionalType(Subscript expr) { expr.getObject().(Name).getId() = "Optional" }

/** True if `expr` is a simple type, i.e., an identifier (excluding builtin types) or an attribute of a simple type. */
predicate isBasicType(Expr expr) {
  expr instanceof Name and not expr instanceof BuiltinType // If expr is a name but not a builtin type
  or
  isBasicType(expr.(Attribute).getObject()) // If expr is an attribute and its object is a basic type
}

/** True if `expr` is a builtin type. */
predicate isBuiltinType(Expr expr) { expr instanceof BuiltinType }

// Predicate to calculate counts of different types of annotations.
predicate typeAnnotationMetrics(
  string category, int overall, int builtin_count, int forward_count, int basic_count,
  int complex_count, int optional_count
) {
  // For parameter annotations
  category = "Parameter annotation" and 
  overall = count(AnnotatedParameter p) and 
  builtin_count = count(AnnotatedParameter p | isBuiltinType(p.getAnnotation())) and 
  forward_count = count(AnnotatedParameter p | isForwardDeclaration(p.getAnnotation())) and 
  basic_count = count(AnnotatedParameter p | isBasicType(p.getAnnotation())) and 
  complex_count = count(AnnotatedParameter p | isComplexType(p.getAnnotation())) and 
  optional_count = count(AnnotatedParameter p | isOptionalType(p.getAnnotation()))
  or
  // For return type annotations
  category = "Return type annotation" and 
  overall = count(FunctionWithReturn f) and 
  builtin_count = count(FunctionWithReturn f | isBuiltinType(f.getAnnotation())) and 
  forward_count = count(FunctionWithReturn f | isForwardDeclaration(f.getAnnotation())) and 
  basic_count = count(FunctionWithReturn f | isBasicType(f.getAnnotation())) and 
  complex_count = count(FunctionWithReturn f | isComplexType(f.getAnnotation())) and 
  optional_count = count(FunctionWithReturn f | isOptionalType(f.getAnnotation()))
  or
  // For annotated assignments
  category = "Annotated assignment" and 
  overall = count(AnnotatedAssignment a) and 
  builtin_count = count(AnnotatedAssignment a | isBuiltinType(a.getAnnotation())) and 
  forward_count = count(AnnotatedAssignment a | isForwardDeclaration(a.getAnnotation())) and 
  basic_count = count(AnnotatedAssignment a | isBasicType(a.getAnnotation())) and 
  complex_count = count(AnnotatedAssignment a | isComplexType(a.getAnnotation())) and 
  optional_count = count(AnnotatedAssignment a | isOptionalType(a.getAnnotation()))
}

// Query statement to select data from the database that satisfies the typeAnnotationMetrics predicate.
from
  string category, int overall, int builtin, int forward, int basic, int complex, int optional
where typeAnnotationMetrics(category, overall, builtin, forward, basic, complex, optional)
select category, overall, builtin, forward, basic, complex, optional