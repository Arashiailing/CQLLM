import py

from StringConcatenation c
where c.getConcatenatedString().contains("request.GET.get") or c.getConcatenatedString().contains("request.POST.get") or c.getConcatenatedString().contains("input()")
select c, "Potential reflected XSS vulnerability due to direct user input in HTML"