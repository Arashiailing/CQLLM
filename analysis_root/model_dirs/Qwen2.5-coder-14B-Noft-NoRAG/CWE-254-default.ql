import python

from FunctionCall call
where call.getCallee().getName() = "pam_authenticate"
  and not call.getArgument(1).toString().contains("PAM_SILENT")
select call, "Potential CWE-254: PamAuthorizationQuery vulnerability detected. The PAM_SILENT flag is not set, which may allow for unauthorized logging or interaction during authentication."