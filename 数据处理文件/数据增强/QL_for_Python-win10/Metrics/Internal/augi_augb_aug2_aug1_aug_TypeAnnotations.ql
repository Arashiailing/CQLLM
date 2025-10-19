/**
 * @name Type metrics
 * @description Analyzes Python type annotations across different code elements,
 *              quantifying annotation patterns in parameters, return types, and assignments.
 *              Categories include built-ins, forward declarations, simple types, 
 *              complex types, and optional types.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents core Python built-in types (e.g., int, str, bool)
class CoreBuiltinType extends Name {
  CoreBuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for code elements supporting type annotations
newtype TAnnotatableElement =
  TAnnotatedFunctionElement(FunctionExpr funcExpr) { exists(funcExpr.getReturns()) } or
  TAnnotatedParameterElement(Parameter param) { exists(param.getAnnotation()) } or
  TAnnotatedAssignmentElement(AnnAssign assign) { exists(assign.getAnnotation()) }

// Abstract base class for elements with type annotations
abstract class AnnotatableElement extends TAnnotatableElement {
  string toString() { result = "AnnotatableElement" }
  abstract Expr getTypeAnnotation();
}

// Function expressions with return type annotations
class AnnotatedFunctionElement extends TAnnotatedFunctionElement, AnnotatableElement {
  FunctionExpr functionExpr;

  AnnotatedFunctionElement() { this = TAnnotatedFunctionElement(functionExpr) }
  override Expr getTypeAnnotation() { result = functionExpr.getReturns() }
}

// Parameters with type annotations
class AnnotatedParameterElement extends TAnnotatedParameterElement, AnnotatableElement {
  Parameter parameter;

  AnnotatedParameterElement() { this = TAnnotatedParameterElement(parameter) }
  override Expr getTypeAnnotation() { result = parameter.getAnnotation() }
}

// Assignment statements with type annotations
class AnnotatedAssignmentElement extends TAnnotatedAssignmentElement, AnnotatableElement {
  AnnAssign annotatedAssign;

  AnnotatedAssignmentElement() { this = TAnnotatedAssignmentElement(annotatedAssign) }
  override Expr getTypeAnnotation() { result = annotatedAssign.getAnnotation() }
}

/** Identifies forward-declared types (string literals) */
predicate isForwardDeclaredType(Expr typeAnnotation) { typeAnnotation instanceof StringLiteral }

/** Identifies complex types that may require deeper analysis */
predicate isComplexType(Expr typeAnnotation) {
  (typeAnnotation instanceof Subscript and not isOptionalType(typeAnnotation)) or
  typeAnnotation instanceof Tuple or
  typeAnnotation instanceof List
}

/** Identifies Optional types (e.g., Optional[...]) */
predicate isOptionalType(Subscript typeAnnotation) { typeAnnotation.getObject().(Name).getId() = "Optional" }

/** Identifies simple non-built-in types (identifiers or attribute chains) */
predicate isSimpleType(Expr typeAnnotation) {
  (typeAnnotation instanceof Name and not typeAnnotation instanceof CoreBuiltinType) or
  isSimpleType(typeAnnotation.(Attribute).getObject())
}

/** Identifies built-in types */
predicate isBuiltinType(Expr typeAnnotation) { typeAnnotation instanceof CoreBuiltinType }

// Computes type annotation metrics for different categories
predicate typeAnnotationMetrics(
  string annotationCategory, int totalAnnotations, int builtinTypeCount, 
  int forwardDeclarationCount, int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  // Parameter annotation metrics calculation
  annotationCategory = "Parameter annotation" and
  totalAnnotations = count(AnnotatedParameterElement paramElement) and
  builtinTypeCount = count(AnnotatedParameterElement paramElement | 
    isBuiltinType(paramElement.getTypeAnnotation())) and
  forwardDeclarationCount = count(AnnotatedParameterElement paramElement | 
    isForwardDeclaredType(paramElement.getTypeAnnotation())) and
  simpleTypeCount = count(AnnotatedParameterElement paramElement | 
    isSimpleType(paramElement.getTypeAnnotation())) and
  complexTypeCount = count(AnnotatedParameterElement paramElement | 
    isComplexType(paramElement.getTypeAnnotation())) and
  optionalTypeCount = count(AnnotatedParameterElement paramElement | 
    isOptionalType(paramElement.getTypeAnnotation()))
  or
  // Return type annotation metrics calculation
  annotationCategory = "Return type annotation" and
  totalAnnotations = count(AnnotatedFunctionElement funcElement) and
  builtinTypeCount = count(AnnotatedFunctionElement funcElement | 
    isBuiltinType(funcElement.getTypeAnnotation())) and
  forwardDeclarationCount = count(AnnotatedFunctionElement funcElement | 
    isForwardDeclaredType(funcElement.getTypeAnnotation())) and
  simpleTypeCount = count(AnnotatedFunctionElement funcElement | 
    isSimpleType(funcElement.getTypeAnnotation())) and
  complexTypeCount = count(AnnotatedFunctionElement funcElement | 
    isComplexType(funcElement.getTypeAnnotation())) and
  optionalTypeCount = count(AnnotatedFunctionElement funcElement | 
    isOptionalType(funcElement.getTypeAnnotation()))
  or
  // Annotated assignment metrics calculation
  annotationCategory = "Annotated assignment" and
  totalAnnotations = count(AnnotatedAssignmentElement assignElement) and
  builtinTypeCount = count(AnnotatedAssignmentElement assignElement | 
    isBuiltinType(assignElement.getTypeAnnotation())) and
  forwardDeclarationCount = count(AnnotatedAssignmentElement assignElement | 
    isForwardDeclaredType(assignElement.getTypeAnnotation())) and
  simpleTypeCount = count(AnnotatedAssignmentElement assignElement | 
    isSimpleType(assignElement.getTypeAnnotation())) and
  complexTypeCount = count(AnnotatedAssignmentElement assignElement | 
    isComplexType(assignElement.getTypeAnnotation())) and
  optionalTypeCount = count(AnnotatedAssignmentElement assignElement | 
    isOptionalType(assignElement.getTypeAnnotation()))
}

// Query execution and results output
from 
  string annotationCategory, int totalAnnotations, int builtinTypeCount, 
  int forwardDeclarationCount, int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  typeAnnotationMetrics(annotationCategory, totalAnnotations, builtinTypeCount, 
                       forwardDeclarationCount, simpleTypeCount, complexTypeCount, optionalTypeCount)
select 
  annotationCategory, totalAnnotations, builtinTypeCount, forwardDeclarationCount, 
  simpleTypeCount, complexTypeCount, optionalTypeCount