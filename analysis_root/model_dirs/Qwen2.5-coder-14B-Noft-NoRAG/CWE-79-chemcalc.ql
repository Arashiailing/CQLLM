import python

from Expr user_input, Expr web_output
where user_input.hasType("str") and web_output = user_input
select web_output, "This expression writes user input directly to a web page, which may lead to a cross-site scripting vulnerability."