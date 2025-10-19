import py

from Call import Call
from Function import Function
from Variable import Variable

query URLRedirectionFromUserInput {
  Call c
  where
    c.getFunction().getName() = "redirect" and
    c.getArgument(0).isFromUserInput()
  select c, "Potential URL redirection based on unvalidated user input"
}