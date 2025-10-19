import python

from Call call
where call.getCallee() = "pickle.loads" or call.getCallee() = "json.loads"
select call, "Potential unsafe deserialization without bounds checking (CWE-119)"