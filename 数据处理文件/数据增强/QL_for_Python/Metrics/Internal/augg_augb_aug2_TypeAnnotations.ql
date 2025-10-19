/**
 * @name Type metrics
 * @description Analyzes and provides statistics on various type annotation patterns in Python codebases.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents core built-in types in Python.
class BuiltinType extends Name {
  // Constructor that identifies instances as one of the fundamental Python types.
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Defines a discriminated union type for elements that can have type annotations.
newtype TTypedElement =
  TFunctionWithReturn(FunctionExpr f) { exists(f.getReturns()) } or // Function expressions with explicit return type
  TAnnotatedParameter(Parameter p) { exists(p.getAnnotation()) } or // Parameters with type annotations
  TAnnotatedAssignment(AnnAssign a) { exists(a.getAnnotation()) } // Variable assignments with type annotations

// Abstract base class for all elements that can have type annotations.
abstract class TypedElement extends TTypedElement {
  // Provides a string representation of the element.
  string toString() { result = "TypedElement" }

  // Abstract method to retrieve the type annotation expression.
  abstract Expr getAnnotation();
}

// Represents function expressions with return type annotations.
class FunctionWithReturn extends TFunctionWithReturn, TypedElement {
  FunctionExpr functionExpr; // The underlying function expression

  // Constructor that binds this instance to a function expression.
  FunctionWithReturn() { this = TFunctionWithReturn(functionExpr) }

  // Retrieves the return type annotation of the function.
  override Expr getAnnotation() { result = functionExpr.getReturns() }
}

// Represents function parameters with type annotations.
class AnnotatedParameter extends TAnnotatedParameter, TypedElement {
  Parameter parameter; // The parameter with annotation

  // Constructor that binds this instance to a parameter.
  AnnotatedParameter() { this = TAnnotatedParameter(parameter) }

  // Retrieves the type annotation of the parameter.
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Represents variable assignments with type annotations.
class AnnotatedAssignment extends TAnnotatedAssignment, TypedElement {
  AnnAssign annotatedAssign; // The annotated assignment statement

  // Constructor that binds this instance to an assignment.
  AnnotatedAssignment() { this = TAnnotatedAssignment(annotatedAssign) }

  // Retrieves the type annotation of the assignment.
  override Expr getAnnotation() { result = annotatedAssign.getAnnotation() }
}

/** Determines if an expression is a string literal used for forward type declarations. */
predicate isForwardDeclaration(Expr e) { e instanceof StringLiteral }

/** Identifies expressions representing complex type structures that require deeper analysis. */
predicate isComplexType(Expr e) {
  e instanceof Subscript and not isOptionalType(e) // Subscript types that are not Optional
  or
  e instanceof Tuple // Tuple type annotations
  or
  e instanceof List // List type annotations
}

/** Checks if a subscript expression represents an Optional type (Optional[...]). */
predicate isOptionalType(Subscript e) { e.getObject().(Name).getId() = "Optional" }

/** Determines if an expression represents a basic type (simple identifier or attribute access). */
predicate isBasicType(Expr e) {
  e instanceof Name and not e instanceof BuiltinType // Non-builtin name types
  or
  isBasicType(e.(Attribute).getObject()) // Attribute access where the object is a basic type
}

/** Checks if an expression represents a built-in Python type. */
predicate isBuiltinType(Expr e) { e instanceof BuiltinType }

// Predicate to compute statistics for different categories of type annotations.
predicate typeAnnotationMetrics(
  string annotationCategory, int totalCount, int builtinTypeCount, int forwardDeclCount, 
  int basicTypeCount, int complexTypeCount, int optionalTypeCount
) {
  // Statistics for parameter annotations
  annotationCategory = "Parameter annotation" and 
  totalCount = count(AnnotatedParameter annotatedParam) and 
  builtinTypeCount = count(AnnotatedParameter annotatedParam | isBuiltinType(annotatedParam.getAnnotation())) and 
  forwardDeclCount = count(AnnotatedParameter annotatedParam | isForwardDeclaration(annotatedParam.getAnnotation())) and 
  basicTypeCount = count(AnnotatedParameter annotatedParam | isBasicType(annotatedParam.getAnnotation())) and 
  complexTypeCount = count(AnnotatedParameter annotatedParam | isComplexType(annotatedParam.getAnnotation())) and 
  optionalTypeCount = count(AnnotatedParameter annotatedParam | isOptionalType(annotatedParam.getAnnotation()))
  or
  // Statistics for return type annotations
  annotationCategory = "Return type annotation" and 
  totalCount = count(FunctionWithReturn annotatedFunc) and 
  builtinTypeCount = count(FunctionWithReturn annotatedFunc | isBuiltinType(annotatedFunc.getAnnotation())) and 
  forwardDeclCount = count(FunctionWithReturn annotatedFunc | isForwardDeclaration(annotatedFunc.getAnnotation())) and 
  basicTypeCount = count(FunctionWithReturn annotatedFunc | isBasicType(annotatedFunc.getAnnotation())) and 
  complexTypeCount = count(FunctionWithReturn annotatedFunc | isComplexType(annotatedFunc.getAnnotation())) and 
  optionalTypeCount = count(FunctionWithReturn annotatedFunc | isOptionalType(annotatedFunc.getAnnotation()))
  or
  // Statistics for annotated assignments
  annotationCategory = "Annotated assignment" and 
  totalCount = count(AnnotatedAssignment annotatedAssign) and 
  builtinTypeCount = count(AnnotatedAssignment annotatedAssign | isBuiltinType(annotatedAssign.getAnnotation())) and 
  forwardDeclCount = count(AnnotatedAssignment annotatedAssign | isForwardDeclaration(annotatedAssign.getAnnotation())) and 
  basicTypeCount = count(AnnotatedAssignment annotatedAssign | isBasicType(annotatedAssign.getAnnotation())) and 
  complexTypeCount = count(AnnotatedAssignment annotatedAssign | isComplexType(annotatedAssign.getAnnotation())) and 
  optionalTypeCount = count(AnnotatedAssignment annotatedAssign | isOptionalType(annotatedAssign.getAnnotation()))
}

// Query to retrieve type annotation statistics.
from
  string annotationCategory, int totalCount, int builtinTypeCount, int forwardDeclCount, 
  int basicTypeCount, int complexTypeCount, int optionalTypeCount
where typeAnnotationMetrics(annotationCategory, totalCount, builtinTypeCount, forwardDeclCount, 
       basicTypeCount, complexTypeCount, optionalTypeCount)
select annotationCategory, totalCount, builtinTypeCount, forwardDeclCount, 
       basicTypeCount, complexTypeCount, optionalTypeCount