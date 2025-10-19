import python

from StringConcatExpr s, CallExpr c
where s.getConcatenatedStrings() contains user_input and c.getCalledFunction() is output_to_html
select c, "Potential reflected XSS vulnerability due to direct user input in HTML output."