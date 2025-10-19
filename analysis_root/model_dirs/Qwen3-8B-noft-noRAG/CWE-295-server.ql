import python

/**
 * @predicate is_insecure_request(Call call)
 * @description Checks if a request lacks proper certificate validation.
 */
from Call call
where 
  (call.getCallee() = "requests.get" or call.getCallee() = "requests.post") and
  (not call.hasParameter("verify") or 
   (call.getParameter("verify").getValue().isLiteral() and 
    call.getParameter("verify").getValue().asLiteral().getValue() == false))
select call, "Potential CWE-295: Request without certificate validation detected."