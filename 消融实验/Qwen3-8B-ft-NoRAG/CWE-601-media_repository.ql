import python

from Call import Call
from Argument import Argument

where Call.getFunction().getName() = "redirect"
select Call, "Potential URL redirection with unvalidated input"