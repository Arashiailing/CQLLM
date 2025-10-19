/**
 * @name HttpHeaderInjectionQuery
 */

import java
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

predicate headerInjection(DataFlow::Node node) {
  exists(API::Node apiNode |
    apiNode = API::moduleImport("email").getMember("message").getMember("Message") and
    (
      apiNode.(Function).getReturn().flowsTo(node)
      or
      apiNode.(Function).getReturn().getAttr("_payload").flowsTo(node)
    )
  )
}

predicate httpHeaderInjection(DataFlow::Node node, string headerName) {
  headerInjection(node) and
  headerName = "_payload"
}