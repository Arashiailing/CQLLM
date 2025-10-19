/**
 * @name Python Type Annotation Metrics
 * @description Analyzes and quantifies various categories of type annotations in Python source code
 * @kind metrics-table
 * @id py/annotation-metrics
 */

import python

// Represents core Python built-in types
class CoreBuiltinType extends Name {
  CoreBuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Defines union type for elements supporting type annotations
newtype TypeAnnotatableEntity =
  FunctionAnnotationEntity(FunctionExpr funcExpr) { exists(funcExpr.getReturns()) } or 
  ParameterAnnotationEntity(Parameter param) { exists(param.getAnnotation()) } or 
  AssignmentAnnotationEntity(AnnAssign annAssign) { exists(annAssign.getAnnotation()) }

// Base class for elements that can have type annotations
abstract class TypeAnnotatedElement extends TypeAnnotatableEntity {
  string toString() { result = "TypeAnnotatedElement" }
  abstract Expr getAnnotation();
}

// Represents functions with return type annotations
class FunctionAnnotation extends FunctionAnnotationEntity, TypeAnnotatedElement {
  FunctionExpr funcExpr;
  FunctionAnnotation() { this = FunctionAnnotationEntity(funcExpr) }
  override Expr getAnnotation() { result = funcExpr.getReturns() }
}

// Represents parameters with type annotations
class ParameterAnnotation extends ParameterAnnotationEntity, TypeAnnotatedElement {
  Parameter param;
  ParameterAnnotation() { this = ParameterAnnotationEntity(param) }
  override Expr getAnnotation() { result = param.getAnnotation() }
}

// Represents assignments with type annotations
class AssignmentAnnotation extends AssignmentAnnotationEntity, TypeAnnotatedElement {
  AnnAssign annAssign;
  AssignmentAnnotation() { this = AssignmentAnnotationEntity(annAssign) }
  override Expr getAnnotation() { result = annAssign.getAnnotation() }
}

// Helper predicates to categorize type annotations
/** Determines if an annotation is a forward-declared type (string literal) */
predicate isStringLiteralType(Expr annotationExpr) { annotationExpr instanceof StringLiteral }

/** Determines if an annotation represents a complex type structure */
predicate isComplexTypeStructure(Expr annotationExpr) {
  annotationExpr instanceof Subscript and not isOptionalTypeAnnotation(annotationExpr)
  or
  annotationExpr instanceof Tuple
  or
  annotationExpr instanceof List
}

/** Determines if an annotation is an Optional type */
predicate isOptionalTypeAnnotation(Subscript annotationExpr) { 
  annotationExpr.getObject().(Name).getId() = "Optional" 
}

/** Determines if an annotation is a simple user-defined type */
predicate isSimpleUserType(Expr annotationExpr) {
  annotationExpr instanceof Name and not annotationExpr instanceof CoreBuiltinType
  or
  isSimpleUserType(annotationExpr.(Attribute).getObject())
}

/** Determines if an annotation is a built-in type */
predicate isBuiltinTypeAnnotation(Expr annotationExpr) { 
  annotationExpr instanceof CoreBuiltinType 
}

// Computes type annotation metrics for different annotation categories
predicate calculateAnnotationMetrics(
  string annotationKind, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  (
    annotationKind = "Parameter annotation" and
    totalCount = count(ParameterAnnotation paramAnnot) and
    builtinCount = count(ParameterAnnotation paramAnnot | isBuiltinTypeAnnotation(paramAnnot.getAnnotation())) and
    forwardDeclCount = count(ParameterAnnotation paramAnnot | isStringLiteralType(paramAnnot.getAnnotation())) and
    simpleTypeCount = count(ParameterAnnotation paramAnnot | isSimpleUserType(paramAnnot.getAnnotation())) and
    complexTypeCount = count(ParameterAnnotation paramAnnot | isComplexTypeStructure(paramAnnot.getAnnotation())) and
    optionalTypeCount = count(ParameterAnnotation paramAnnot | isOptionalTypeAnnotation(paramAnnot.getAnnotation()))
  )
  or
  (
    annotationKind = "Return type annotation" and
    totalCount = count(FunctionAnnotation funcAnnot) and
    builtinCount = count(FunctionAnnotation funcAnnot | isBuiltinTypeAnnotation(funcAnnot.getAnnotation())) and
    forwardDeclCount = count(FunctionAnnotation funcAnnot | isStringLiteralType(funcAnnot.getAnnotation())) and
    simpleTypeCount = count(FunctionAnnotation funcAnnot | isSimpleUserType(funcAnnot.getAnnotation())) and
    complexTypeCount = count(FunctionAnnotation funcAnnot | isComplexTypeStructure(funcAnnot.getAnnotation())) and
    optionalTypeCount = count(FunctionAnnotation funcAnnot | isOptionalTypeAnnotation(funcAnnot.getAnnotation()))
  )
  or
  (
    annotationKind = "Annotated assignment" and
    totalCount = count(AssignmentAnnotation assignAnnot) and
    builtinCount = count(AssignmentAnnotation assignAnnot | isBuiltinTypeAnnotation(assignAnnot.getAnnotation())) and
    forwardDeclCount = count(AssignmentAnnotation assignAnnot | isStringLiteralType(assignAnnot.getAnnotation())) and
    simpleTypeCount = count(AssignmentAnnotation assignAnnot | isSimpleUserType(assignAnnot.getAnnotation())) and
    complexTypeCount = count(AssignmentAnnotation assignAnnot | isComplexTypeStructure(assignAnnot.getAnnotation())) and
    optionalTypeCount = count(AssignmentAnnotation assignAnnot | isOptionalTypeAnnotation(assignAnnot.getAnnotation()))
  )
}

// Query execution and result projection
from
  string annotationKind, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  calculateAnnotationMetrics(annotationKind, totalCount, builtinCount, forwardDeclCount, 
                             simpleTypeCount, complexTypeCount, optionalTypeCount)
select annotationKind, totalCount, builtinCount, forwardDeclCount, simpleTypeCount, complexTypeCount, optionalTypeCount