import python

from Call call
where call.getCallee().getName() in ["subprocess.run", "os.system", "open", "subprocess.check_output"]
  and not exists (call.getAncestors() + call.getPredecessors() | Call c where c.getCallee().getName() in ["check_permission", "has_permission", "user_has_permission", "is_authorized"])
select call, "Missing permission check before executing sensitive operation"