import python

from Call call
where call.getCallee() = "pam.authenticate"
select call, "Potential CWE-254: PamAuthorizationQuery - missing success check on pam.authenticate call."