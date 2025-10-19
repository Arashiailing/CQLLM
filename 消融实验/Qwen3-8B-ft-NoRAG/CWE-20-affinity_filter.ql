import python

from Call call, Assign assign
where call.getTarget() = "input" and assign.getVariable() = call.getVariable()
select assign.getVariable(), "Unvalidated input used"