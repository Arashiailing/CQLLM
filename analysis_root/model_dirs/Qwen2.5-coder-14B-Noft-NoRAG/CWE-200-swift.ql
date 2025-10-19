import python

from Call call, DataFlow::Node src, DataFlow::Node sink
where call.getCallee().getName() = "logging.info" or call.getCallee().getName() = "logging.debug"
  and src instanceof DataFlow::ExprNode
  and sink instanceof DataFlow::ExprNode
  and DataFlow::localFlow(src, sink)
select src, "Sensitive information is being logged in cleartext."