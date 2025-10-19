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
  FunctionExpr functionExpr; // Function expression

  // Constructor that initializes the functionExpr attribute.
  FunctionWithReturn() { this = TFunctionWithReturn(functionExpr) }

  // Overrides getAnnotation method to return the function's return type annotation.
  override Expr getAnnotation() { result = functionExpr.getReturns() }
}

// Class AnnotatedParameter, inheriting from TAnnotatedParameter and TypedElement, representing parameters with annotations.
class AnnotatedParameter extends TAnnotatedParameter, TypedElement {
  Parameter parameter; // Parameter

  // Constructor that initializes the parameter attribute.
  AnnotatedParameter() { this = TAnnotatedParameter(parameter) }

  // Overrides getAnnotation method to return the parameter's annotation.
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Class AnnotatedAssignment, inheriting from TAnnotatedAssignment and TypedElement, representing assignment statements with annotations.
class AnnotatedAssignment extends TAnnotatedAssignment, TypedElement {
  AnnAssign annotatedAssign; // Assignment statement

  // Constructor that initializes the annotatedAssign attribute.
  AnnotatedAssignment() { this = TAnnotatedAssignment(annotatedAssign) }

  // Overrides getAnnotation method to return the assignment's annotation.
  override Expr getAnnotation() { result = annotatedAssign.getAnnotation() }
}

/** True if `e` is a string literal used as a forward declaration of a type. */
predicate isForwardDeclaration(Expr e) { e instanceof StringLiteral }

/** True if `e` represents a type that is complex to analyze. */
predicate isComplexType(Expr e) {
  e instanceof Subscript and not isOptionalType(e) // If e is a subscript but not an optional type
  or
  e instanceof Tuple // If e is a tuple type
  or
  e instanceof List // If e is a list type
}

/** True if `e` is a type of the form `Optional[...]`. */
predicate isOptionalType(Subscript e) { e.getObject().(Name).getId() = "Optional" }

/** True if `e` is a simple type, i.e., an identifier (excluding builtin types) or an attribute of a simple type. */
predicate isBasicType(Expr e) {
  e instanceof Name and not e instanceof BuiltinType // If e is a name but not a builtin type
  or
  isBasicType(e.(Attribute).getObject()) // If e is an attribute and its object is a basic type
}

/** True if `e` is a builtin type. */
predicate isBuiltinType(Expr e) { e instanceof BuiltinType }

// Predicate to calculate counts of different types of annotations.
predicate typeAnnotationMetrics(
  string category, int overall, int builtin_count, int forward_count, int basic_count,
  int complex_count, int optional_count
) {
  // For parameter annotations
  category = "Parameter annotation" and 
  overall = count(AnnotatedParameter param) and 
  builtin_count = count(AnnotatedParameter param | isBuiltinType(param.getAnnotation())) and 
  forward_count = count(AnnotatedParameter param | isForwardDeclaration(param.getAnnotation())) and 
  basic_count = count(AnnotatedParameter param | isBasicType(param.getAnnotation())) and 
  complex_count = count(AnnotatedParameter param | isComplexType(param.getAnnotation())) and 
  optional_count = count(AnnotatedParameter param | isOptionalType(param.getAnnotation()))
  or
  // For return type annotations
  category = "Return type annotation" and 
  overall = count(FunctionWithReturn func) and 
  builtin_count = count(FunctionWithReturn func | isBuiltinType(func.getAnnotation())) and 
  forward_count = count(FunctionWithReturn func | isForwardDeclaration(func.getAnnotation())) and 
  basic_count = count(FunctionWithReturn func | isBasicType(func.getAnnotation())) and 
  complex_count = count(FunctionWithReturn func | isComplexType(func.getAnnotation())) and 
  optional_count = count(FunctionWithReturn func | isOptionalType(func.getAnnotation()))
  or
  // For annotated assignments
  category = "Annotated assignment" and 
  overall = count(AnnotatedAssignment assign) and 
  builtin_count = count(AnnotatedAssignment assign | isBuiltinType(assign.getAnnotation())) and 
  forward_count = count(AnnotatedAssignment assign | isForwardDeclaration(assign.getAnnotation())) and 
  basic_count = count(AnnotatedAssignment assign | isBasicType(assign.getAnnotation())) and 
  complex_count = count(AnnotatedAssignment assign | isComplexType(assign.getAnnotation())) and 
  optional_count = count(AnnotatedAssignment assign | isOptionalType(assign.getAnnotation()))
}

// Query statement to select data from the database that satisfies the typeAnnotationMetrics predicate.
from
  string category, int overall, int builtin, int forward, int basic, int complex, int optional
where typeAnnotationMetrics(category, overall, builtin, forward, basic, complex, optional)
select category, overall, builtin, forward, basic, complex, optional