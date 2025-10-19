import py

from Call import Call
from Argument import Argument

// Define functions that perform URL redirection
def isRedirectFunction(func):
    return func.getName() in ["redirect", "send_redirect", "redirect_to", "url_for"]

// Find all calls to redirect functions
redirectCalls = Call.where(isRedirectFunction(Call.getFunction()))

// Check if any argument is user-controlled and not validated
for call in redirectCalls:
    args = call.getArguments()
    for arg in args:
        if arg.getSource().isUserInput() and not arg.getExpression().isLiteral():
            select call, "Potential URL redirect without validation"