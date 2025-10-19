import python
import Dataflow

/**
 * A query to detect reflected cross-site scripting (XSS) vulnerabilities
 * in Python web applications.
 */

class ReflectedXss extends Dataflow::Configuration {
  ReflectedXss() {
    this = "ReflectedXss"
  }

  override predicate isSource(Dataflow::Node source) {
    exists(HttpRequest request | request.hasBody() and request.getBody().contains(source))
  }

  override predicate isSink(Dataflow::Node sink) {
    exists(HttpResponse response | response.hasBody() and response.getBody().contains(sink))
  }
}

from ReflectedXss config, Dataflow::Node source, Dataflow::Node sink
where config.hasFlow(source, sink)
select sink, "This node is a potential XSS sink, as it contains user input from a request body."