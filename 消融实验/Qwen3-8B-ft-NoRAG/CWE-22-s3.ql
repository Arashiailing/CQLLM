import python

from Call call
where call.getTarget() = "os.path.join" or call.getTarget() = "operator.add" or call.getTarget() = "format"
select call, "Potential Path Injection vulnerability detected in path construction."