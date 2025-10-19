import py

from AssignmentExpr assign
where assign.lhs is a FieldAccessExpr with name "Location"
  and assign.rhs is a Variable
select assign, "Potential URL redirection based on unvalidated user input."