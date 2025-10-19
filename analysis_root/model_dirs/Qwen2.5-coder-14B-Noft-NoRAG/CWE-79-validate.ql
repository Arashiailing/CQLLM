import python

from WebInput input, WebOutput output
where input.getOrigin() = "user" and
      output.getValue() = input.getValue()
select output, "This output directly reflects user input, which may lead to a reflected XSS vulnerability."