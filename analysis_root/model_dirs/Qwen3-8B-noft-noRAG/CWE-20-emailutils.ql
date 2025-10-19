import python
import semmle.code.cpp.dataflow.DataFlow

/**
 * @predicate
 * @param source - The source of the potentially unsafe input.
 * @param sink - The sink where the unvalidated input is used in an HTTP header.
 */
predicate httpHeaderInjection(Source source, Sink sink) {
  exists (Call c, Assign a |
    c.getFunction().getName() = "set_header" or
    c.getFunction().getName() = "add_header" or
    a.getLeftHandSide().getName() = "headers" and
    a.getRightHandSide().getExpression() = c.getArgument(0)
    and
    source.flowTo(c.getArgument(0)) and
    sink.flowFrom(c.getArgument(0))
  )
}

/** 
 * Define sources as inputs from HTTP request parameters.
 * This includes query parameters, form data, cookies, etc.
 */
predicate isHttpRequestSource(Expression expr) {
  expr.hasType("str") and
  expr.isPartOf("request.args") or
  expr.isPartOf("request.form") or
  expr.isPartOf("request.cookies")
}

/**
 * Define sinks as assignments to HTTP headers.
 * Includes direct assignment to 'headers' dictionary or calls to set/add header functions.
 */
predicate isHttpHeaderSink(Expression expr) {
  expr.getType().isDictionary() and
  expr.getName() = "headers"
  
  or
  
  expr.isCall() and
  expr.getFunction().getName() = "set_header" or
  expr.getFunction().getName() = "add_header"
}

from Source s, Sink t
where isHttpRequestSource(s) and isHttpHeaderSink(t) and httpHeaderInjection(s, t)
select t, "Potential HTTP Header Injection via unvalidated input"