import python
import semmle.code.python.dataflow.DataFlow

/**
 * @name HTTP Header Injection
 * @description Detects potential HTTP header injection by identifying assignments to HTTP headers that may originate from untrusted sources.
 */
class HttpHeadersAssignment extends AssignExpr {
  HttpHeaderInjection(HttpHeaders headers, String key, Expr value) {
    this.getLHS().isMemberAccess().getBase().hasName("headers") 
    and this.getRHS().isVariable()
    and this.getLHS().isMemberAccess().getMethod().hasName("add")
    and this.getRHS().isUntrustedSource()
  }
  
  /**
   * @name Untrusted Source
   * @description Identifies expressions that are considered untrusted inputs.
   */
  predicate isUntrustedSource(Expr expr) {
    expr.isParameter() or
    expr.isAttributeAccess().getBase().hasName("request") or
    expr.isAttributeAccess().getBase().hasName("form") or
    expr.isAttributeAccess().getBase().hasName("args") or
    expr.isCall().getMethod().hasName("get")
  }
}