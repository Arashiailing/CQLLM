import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.Concepts

from Http::Client::Request request, DataFlow::Node disablingNode, DataFlow::Node origin
where request.disablesCertificateValidation(disablingNode, origin)
select request, "Request without certificate validation"