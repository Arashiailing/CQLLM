import python

from Call call
where call.getCallee().getName() = "check_permission" and call.getArguments().size() < 2
select call, "Potential CWE-269: Improper Privilege Management"