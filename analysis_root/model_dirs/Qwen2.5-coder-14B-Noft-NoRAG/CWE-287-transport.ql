import python

/**
 * Query to detect CWE-287: Improper Authentication
 * This query looks for cases where an actor claims to have a given identity,
 * but the product does not prove or insufficiently proves that the claim is correct.
 */

from Call call, Function function
where function.getName() = "authenticate" and
      call.getCallee() = function and
      not exists(call.getArgument(0).getAPredecessor() instanceof SecurityCheck)
select call, "This authentication call does not have a sufficient security check."