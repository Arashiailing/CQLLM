import py

from CallExpr import CallExpr
where CallExpr.getFunctionName() in ("print", "logging.info", "logging.warning", "logging.debug", "logging.error")
and CallExpr.getArgument(0).isExternalSource()
select CallExpr, "Potential CWE-134: Use of externally-controlled format string"