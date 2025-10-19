import python

/**
 * @name CWE-264: Unsafe Deserialization
 * @description Detects potential unsafe deserialization vulnerabilities in Python code.
 * @id py/bccache
 */

from Call call, Module module
where call.getCallee().getName() = "loads" and
      module.getName() = "pickle"
select call, "This call to pickle.loads may be vulnerable to unsafe deserialization."