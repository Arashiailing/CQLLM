import python
import semmle.python.security.dataflow.SqlInjection

class SqlInjectionQuery extends SqlInjection {
  SqlInjectionQuery() {
    this.getSink() instanceof StringConcatenationExpr
  }
}