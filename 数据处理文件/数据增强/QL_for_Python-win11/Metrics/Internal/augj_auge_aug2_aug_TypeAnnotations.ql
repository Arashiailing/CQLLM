/**
 * @name Type metrics
 * @description Computes metrics for different kinds of type annotations in Python code, 
 *              including parameters, return types, and annotated assignments.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents built-in Python types such as int, float, str, etc.
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that can have type annotations
newtype TAnnotatableElement =
  TAnnotatedFunctionElement(FunctionExpr func) { exists(func.getReturns()) } or
  TAnnotatedParameterElement(Parameter param) { exists(param.getAnnotation()) } or
  TAnnotatedAssignmentElement(AnnAssign stmt) { exists(stmt.getAnnotation()) }

// Abstract base class for all elements that can have type annotations
abstract class AnnotatableElement extends TAnnotatableElement {
  string toString() { result = "AnnotatableElement" }
  abstract Expr getAnnotationExpr();
}

// Function expressions with return type annotations
class AnnotatedFunctionElement extends TAnnotatedFunctionElement, AnnotatableElement {
  FunctionExpr functionExpression;

  AnnotatedFunctionElement() { this = TAnnotatedFunctionElement(functionExpression) }
  override Expr getAnnotationExpr() { result = functionExpression.getReturns() }
}

// Parameters with type annotations
class AnnotatedParameterElement extends TAnnotatedParameterElement, AnnotatableElement {
  Parameter parameterVariable;

  AnnotatedParameterElement() { this = TAnnotatedParameterElement(parameterVariable) }
  override Expr getAnnotationExpr() { result = parameterVariable.getAnnotation() }
}

// Assignment statements with type annotations
class AnnotatedAssignmentElement extends TAnnotatedAssignmentElement, AnnotatableElement {
  AnnAssign assignmentStatement;

  AnnotatedAssignmentElement() { this = TAnnotatedAssignmentElement(assignmentStatement) }
  override Expr getAnnotationExpr() { result = assignmentStatement.getAnnotation() }
}

/** Determines if an annotation is a forward declaration using string literal */
predicate isForwardDeclaration(Expr annotationExpression) { 
  annotationExpression instanceof StringLiteral 
}

/** Determines if an annotation represents a complex type construct */
predicate isComplexType(Expr annotationExpression) {
  (annotationExpression instanceof Subscript and not isOptionalType(annotationExpression)) or
  annotationExpression instanceof Tuple or
  annotationExpression instanceof List
}

/** Determines if an annotation is an Optional type annotation */
predicate isOptionalType(Subscript annotationExpression) { 
  annotationExpression.getObject().(Name).getId() = "Optional" 
}

/** Determines if an annotation is a simple non-built-in type identifier */
predicate isSimpleType(Expr annotationExpression) {
  (annotationExpression instanceof Name and not annotationExpression instanceof BuiltinType) or
  (annotationExpression instanceof Attribute and isSimpleType(annotationExpression.(Attribute).getObject()))
}

/** Determines if an annotation is a built-in type */
predicate isBuiltinType(Expr annotationExpression) { 
  annotationExpression instanceof BuiltinType 
}

// Computes type annotation metrics for each annotation category
predicate computeTypeAnnotationMetrics(
  string annotationCategory, int totalAnnotations, int builtinTypeCount, 
  int forwardDeclarationCount, int simpleTypeCount, int complexTypeCount, 
  int optionalTypeCount
) {
  // Metrics for parameter annotations
  annotationCategory = "Parameter annotation" and
  totalAnnotations = count(AnnotatedParameterElement param) and
  builtinTypeCount = count(AnnotatedParameterElement param | isBuiltinType(param.getAnnotationExpr())) and
  forwardDeclarationCount = count(AnnotatedParameterElement param | isForwardDeclaration(param.getAnnotationExpr())) and
  simpleTypeCount = count(AnnotatedParameterElement param | isSimpleType(param.getAnnotationExpr())) and
  complexTypeCount = count(AnnotatedParameterElement param | isComplexType(param.getAnnotationExpr())) and
  optionalTypeCount = count(AnnotatedParameterElement param | isOptionalType(param.getAnnotationExpr()))
  or
  // Metrics for return type annotations
  annotationCategory = "Return type annotation" and
  totalAnnotations = count(AnnotatedFunctionElement func) and
  builtinTypeCount = count(AnnotatedFunctionElement func | isBuiltinType(func.getAnnotationExpr())) and
  forwardDeclarationCount = count(AnnotatedFunctionElement func | isForwardDeclaration(func.getAnnotationExpr())) and
  simpleTypeCount = count(AnnotatedFunctionElement func | isSimpleType(func.getAnnotationExpr())) and
  complexTypeCount = count(AnnotatedFunctionElement func | isComplexType(func.getAnnotationExpr())) and
  optionalTypeCount = count(AnnotatedFunctionElement func | isOptionalType(func.getAnnotationExpr()))
  or
  // Metrics for annotated assignments
  annotationCategory = "Annotated assignment" and
  totalAnnotations = count(AnnotatedAssignmentElement assign) and
  builtinTypeCount = count(AnnotatedAssignmentElement assign | isBuiltinType(assign.getAnnotationExpr())) and
  forwardDeclarationCount = count(AnnotatedAssignmentElement assign | isForwardDeclaration(assign.getAnnotationExpr())) and
  simpleTypeCount = count(AnnotatedAssignmentElement assign | isSimpleType(assign.getAnnotationExpr())) and
  complexTypeCount = count(AnnotatedAssignmentElement assign | isComplexType(assign.getAnnotationExpr())) and
  optionalTypeCount = count(AnnotatedAssignmentElement assign | isOptionalType(assign.getAnnotationExpr()))
}

// Main query execution
from 
  string annotationCategory, int totalAnnotations, int builtinTypeCount, 
  int forwardDeclarationCount, int simpleTypeCount, int complexTypeCount, 
  int optionalTypeCount
where 
  computeTypeAnnotationMetrics(annotationCategory, totalAnnotations, builtinTypeCount, 
                              forwardDeclarationCount, simpleTypeCount, complexTypeCount, 
                              optionalTypeCount)
select 
  annotationCategory, totalAnnotations, builtinTypeCount, forwardDeclarationCount, 
  simpleTypeCount, complexTypeCount, optionalTypeCount