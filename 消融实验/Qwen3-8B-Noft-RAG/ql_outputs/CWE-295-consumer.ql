import python
private import semmle.python.dataflow.new.DataFlow
private import semmle.python.Concepts

from Http::Client::Request request, DataFlow::Node disablingNode, DataFlow::Node origin, string ending
where request.disablesCertificateValidation(disablingNode, origin)
select request, "Request without certificate validation can allow man-in-the-middle attacks."