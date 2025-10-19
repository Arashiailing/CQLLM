import python

/**
 * Query for CWE-287: Improper Authentication (PyGPGI variant)
 */
from Call call
where call.getCallee().getName() = "authenticate" and 
      call.getArgument(0).getType().getFullyQualifiedName() = "str" and 
      call.getArgument(1).getType().getFullyQualifiedName() = "str" and 
      not (exists(Call c | c.getCallee().getName() = "verify_signature" and 
                    c.getContainingFunction().getAncestors(Function).has(c.getFunction())))
select call, "Potential improper authentication: Credentials are being used without proper verification"