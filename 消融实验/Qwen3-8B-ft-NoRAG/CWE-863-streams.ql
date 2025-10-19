import py

from FunctionCall call
where call.name = "check_permission" or call.name = "has_permission" or call.name = "is_authorized"
select call, "Potential incorrect authorization check"