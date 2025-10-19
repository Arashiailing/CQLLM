import semmle.python.dataflow.PythonDataFlow

from Call call
where call.getMethod().getFullyQualifiedName() = "array.array.frombytes"
select call, "Potential CWE-120: Buffer copy without checking size of input"