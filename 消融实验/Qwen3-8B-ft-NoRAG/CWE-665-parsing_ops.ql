import py

/**
 * Detects potential unsafe deserialization using pickle module in Python.
 * This query identifies calls to pickle.load() and pickle.loads() which could
 * lead to CWE-665: Unsafe Deserialization if the input data is untrusted.
 */
from Call call
where call.getModule().getName() = "pickle"
  and (call.getMethod().getName() = "load" or call.getMethod().getName() = "loads")
select call, "Potential unsafe deserialization using pickle module"