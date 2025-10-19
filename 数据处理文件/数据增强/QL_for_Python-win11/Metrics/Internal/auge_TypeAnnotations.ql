/**
 * @name Type metrics
 * @description Quantifies different categories of type annotations in Python code
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents Python's fundamental built-in types
class FundamentalType extends Name {
  FundamentalType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that can carry type annotations
newtype TAnnotatedElement =
  TFuncWithReturn(FunctionExpr f) { exists(f.getReturns()) } or  // Functions with return type annotations
  TParamWithAnnotation(Parameter p) { exists(p.getAnnotation()) } or  // Parameters with type annotations
  TAssignWithAnnotation(AnnAssign a) { exists(a.getAnnotation()) }  // Variable assignments with type annotations

// Base class for all annotatable elements
abstract class AnnotatedElement extends TAnnotatedElement {
  string toString() { result = "AnnotatedElement" }
  abstract Expr getTypeAnnotation();
}

// Represents functions with return type annotations
class TypedFunction extends TFuncWithReturn, AnnotatedElement {
  FunctionExpr funcExpr;

  TypedFunction() { this = TFuncWithReturn(funcExpr) }
  override Expr getTypeAnnotation() { result = funcExpr.getReturns() }
}

// Represents parameters with type annotations
class TypedParameter extends TParamWithAnnotation, AnnotatedElement {
  Parameter param;

  TypedParameter() { this = TParamWithAnnotation(param) }
  override Expr getTypeAnnotation() { result = param.getAnnotation() }
}

// Represents variable assignments with type annotations
class TypedAssignment extends TAssignWithAnnotation, AnnotatedElement {
  AnnAssign assignStmt;

  TypedAssignment() { this = TAssignWithAnnotation(assignStmt) }
  override Expr getTypeAnnotation() { result = assignStmt.getAnnotation() }
}

// Type classification predicates
/** Identifies forward type declarations (string literals) */
predicate is_forward_decl(Expr e) { e instanceof StringLiteral }

/** Identifies complex type structures */
predicate is_complex_type(Expr e) {
  e instanceof Subscript and not is_optional_type(e)  // Non-optional subscripted types
  or
  e instanceof Tuple  // Tuple type annotations
  or
  e instanceof List  // List type annotations
}

/** Identifies Optional[...] type constructs */
predicate is_optional_type(Subscript e) { e.getObject().(Name).getId() = "Optional" }

/** Identifies simple type references (non-built-in names or attributes) */
predicate is_simple_type(Expr e) {
  e instanceof Name and not e instanceof FundamentalType  // Non-built-in names
  or
  is_simple_type(e.(Attribute).getObject())  // Attributes of simple types
}

/** Identifies built-in type references */
predicate is_fundamental_type(Expr e) { e instanceof FundamentalType }

// Aggregates type annotation metrics
predicate annotation_metrics(
  string category, int totalCount, int fundamentalCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalCount
) {
  // Parameter annotation metrics
  category = "Parameter annotation" and
  totalCount = count(TypedParameter p) and
  fundamentalCount = count(TypedParameter p | is_fundamental_type(p.getTypeAnnotation())) and
  forwardDeclCount = count(TypedParameter p | is_forward_decl(p.getTypeAnnotation())) and
  simpleTypeCount = count(TypedParameter p | is_simple_type(p.getTypeAnnotation())) and
  complexTypeCount = count(TypedParameter p | is_complex_type(p.getTypeAnnotation())) and
  optionalCount = count(TypedParameter p | is_optional_type(p.getTypeAnnotation()))
  
  or
  // Return type annotation metrics
  category = "Return type annotation" and
  totalCount = count(TypedFunction f) and
  fundamentalCount = count(TypedFunction f | is_fundamental_type(f.getTypeAnnotation())) and
  forwardDeclCount = count(TypedFunction f | is_forward_decl(f.getTypeAnnotation())) and
  simpleTypeCount = count(TypedFunction f | is_simple_type(f.getTypeAnnotation())) and
  complexTypeCount = count(TypedFunction f | is_complex_type(f.getTypeAnnotation())) and
  optionalCount = count(TypedFunction f | is_optional_type(f.getTypeAnnotation()))
  
  or
  // Annotated assignment metrics
  category = "Annotated assignment" and
  totalCount = count(TypedAssignment a) and
  fundamentalCount = count(TypedAssignment a | is_fundamental_type(a.getTypeAnnotation())) and
  forwardDeclCount = count(TypedAssignment a | is_forward_decl(a.getTypeAnnotation())) and
  simpleTypeCount = count(TypedAssignment a | is_simple_type(a.getTypeAnnotation())) and
  complexTypeCount = count(TypedAssignment a | is_complex_type(a.getTypeAnnotation())) and
  optionalCount = count(TypedAssignment a | is_optional_type(a.getTypeAnnotation()))
}

// Query execution
from 
  string category, int totalCount, int fundamentalCount, int forwardDeclCount,
  int simpleTypeCount, int complexTypeCount, int optionalCount
where 
  annotation_metrics(category, totalCount, fundamentalCount, forwardDeclCount, 
                    simpleTypeCount, complexTypeCount, optionalCount)
select 
  category, totalCount, fundamentalCount, forwardDeclCount, 
  simpleTypeCount, complexTypeCount, optionalCount