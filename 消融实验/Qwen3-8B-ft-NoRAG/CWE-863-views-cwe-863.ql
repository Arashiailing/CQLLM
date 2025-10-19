import python

from Call call
where call.getMethod().getName() = "has_permission"
select call, "Potential CWE-863: Incorrect authorization check"