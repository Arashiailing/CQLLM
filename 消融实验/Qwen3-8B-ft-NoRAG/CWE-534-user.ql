import python

from Call call
where call.getCallee().getName() in ["debug", "info", "warning", "error", "critical"]
select call, "Potential CWE-534: Sensitive information stored in log file."