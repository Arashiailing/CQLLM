/**
 * @name Type metrics
 * @description Quantifies different categories of type annotations in Python code,
 *              including parameter annotations, return types, and annotated assignments.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents Python built-in types (e.g., int, str, bool)
class PyBuiltinType extends Name {
  PyBuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that can have type annotations
newtype TAnnotatableElement =
  TAnnotatedFunctionElement(FunctionExpr func) { exists(func.getReturns()) } or
  TAnnotatedParameterElement(Parameter param) { exists(param.getAnnotation()) } or
  TAnnotatedAssignmentElement(AnnAssign assign) { exists(assign.getAnnotation()) }

// Abstract base class for elements with type annotations
abstract class AnnotatableElement extends TAnnotatableElement {
  string toString() { result = "AnnotatableElement" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
class AnnotatedFunctionElement extends TAnnotatedFunctionElement, AnnotatableElement {
  FunctionExpr funcExpr;

  AnnotatedFunctionElement() { this = TAnnotatedFunctionElement(funcExpr) }
  override Expr getAnnotation() { result = funcExpr.getReturns() }
}

// Parameters with type annotations
class AnnotatedParameterElement extends TAnnotatedParameterElement, AnnotatableElement {
  Parameter param;

  AnnotatedParameterElement() { this = TAnnotatedParameterElement(param) }
  override Expr getAnnotation() { result = param.getAnnotation() }
}

// Assignment statements with type annotations
class AnnotatedAssignmentElement extends TAnnotatedAssignmentElement, AnnotatableElement {
  AnnAssign assign;

  AnnotatedAssignmentElement() { this = TAnnotatedAssignmentElement(assign) }
  override Expr getAnnotation() { result = assign.getAnnotation() }
}

/** Holds if `typeAnnotation` is a forward-declared type (string literal). */
predicate is_forward_declaration(Expr typeAnnotation) { typeAnnotation instanceof StringLiteral }

/** Holds if `typeAnnotation` is a complex type that may be difficult to analyze. */
predicate is_complex_type(Expr typeAnnotation) {
  (typeAnnotation instanceof Subscript and not is_optional_type(typeAnnotation)) or
  typeAnnotation instanceof Tuple or
  typeAnnotation instanceof List
}

/** Holds if `typeAnnotation` is an Optional type (e.g., Optional[...]). */
predicate is_optional_type(Subscript typeAnnotation) { typeAnnotation.getObject().(Name).getId() = "Optional" }

/** Holds if `typeAnnotation` is a simple type (non-built-in identifier or attribute chain). */
predicate is_simple_type(Expr typeAnnotation) {
  (typeAnnotation instanceof Name and not typeAnnotation instanceof PyBuiltinType) or
  is_simple_type(typeAnnotation.(Attribute).getObject())
}

/** Holds if `typeAnnotation` is a built-in type. */
predicate is_builtin_type(Expr typeAnnotation) { typeAnnotation instanceof PyBuiltinType }

// Computes metrics for different categories of type annotations
predicate type_annotation_metrics(
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  // Parameter annotation metrics
  (
    category = "Parameter annotation" and
    totalCount = count(AnnotatedParameterElement annotatedParam) and
    builtinCount = count(AnnotatedParameterElement annotatedParam | is_builtin_type(annotatedParam.getAnnotation())) and
    forwardDeclCount = count(AnnotatedParameterElement annotatedParam | is_forward_declaration(annotatedParam.getAnnotation())) and
    simpleTypeCount = count(AnnotatedParameterElement annotatedParam | is_simple_type(annotatedParam.getAnnotation())) and
    complexTypeCount = count(AnnotatedParameterElement annotatedParam | is_complex_type(annotatedParam.getAnnotation())) and
    optionalTypeCount = count(AnnotatedParameterElement annotatedParam | is_optional_type(annotatedParam.getAnnotation()))
  )
  or
  // Return type annotation metrics
  (
    category = "Return type annotation" and
    totalCount = count(AnnotatedFunctionElement annotatedFunc) and
    builtinCount = count(AnnotatedFunctionElement annotatedFunc | is_builtin_type(annotatedFunc.getAnnotation())) and
    forwardDeclCount = count(AnnotatedFunctionElement annotatedFunc | is_forward_declaration(annotatedFunc.getAnnotation())) and
    simpleTypeCount = count(AnnotatedFunctionElement annotatedFunc | is_simple_type(annotatedFunc.getAnnotation())) and
    complexTypeCount = count(AnnotatedFunctionElement annotatedFunc | is_complex_type(annotatedFunc.getAnnotation())) and
    optionalTypeCount = count(AnnotatedFunctionElement annotatedFunc | is_optional_type(annotatedFunc.getAnnotation()))
  )
  or
  // Annotated assignment metrics
  (
    category = "Annotated assignment" and
    totalCount = count(AnnotatedAssignmentElement annotatedAssign) and
    builtinCount = count(AnnotatedAssignmentElement annotatedAssign | is_builtin_type(annotatedAssign.getAnnotation())) and
    forwardDeclCount = count(AnnotatedAssignmentElement annotatedAssign | is_forward_declaration(annotatedAssign.getAnnotation())) and
    simpleTypeCount = count(AnnotatedAssignmentElement annotatedAssign | is_simple_type(annotatedAssign.getAnnotation())) and
    complexTypeCount = count(AnnotatedAssignmentElement annotatedAssign | is_complex_type(annotatedAssign.getAnnotation())) and
    optionalTypeCount = count(AnnotatedAssignmentElement annotatedAssign | is_optional_type(annotatedAssign.getAnnotation()))
  )
}

// Query execution and results output
from 
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  type_annotation_metrics(category, totalCount, builtinCount, forwardDeclCount, 
                         simpleTypeCount, complexTypeCount, optionalTypeCount)
select 
  category, totalCount, builtinCount, forwardDeclCount, 
  simpleTypeCount, complexTypeCount, optionalTypeCount