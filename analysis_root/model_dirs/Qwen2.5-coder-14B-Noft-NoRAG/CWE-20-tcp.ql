import python

/**
 * This query detects CWE-20: Improper Input Validation.
 * It looks for cases where user input is logged without proper validation.
 */
from Call call, DataFlow::Node input, DataFlow::Node log
where call.getCallee().getName() = "log" and
      DataFlow::localFlow(input, call.getArgument(0)) and
      not exists(DataFlow::Node validation |
        DataFlow::localFlow(input, validation) and
        validation instanceof Call and
        validation.getCallee().getName() = "validate"
      )
select call, "Logging user input without proper validation."