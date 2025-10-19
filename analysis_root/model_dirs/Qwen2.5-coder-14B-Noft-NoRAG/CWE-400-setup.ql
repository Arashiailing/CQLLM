import python

/**
 * Detects CWE-400: Uncontrolled Resource Consumption in Python setup.py files.
 */
from File setupPy, CallExpression call
where
  setupPy.getName() = "setup.py" and
  call.getCallee().getName() = "add_files" and
  not exists(call.getArgument(0).getAPrecedingArgument())
select
  call,
  "Potential CWE-400: Uncontrolled Resource Consumption detected in setup.py."