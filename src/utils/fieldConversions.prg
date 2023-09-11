#include "hmg.ch"

function date_as_string(date)
    local response := ""
    if !Empty(date)
        response := Transform(DToS(date), "@R 9999-99-99")
    endif
return response

function string_as_DateTime(stringDate, lTDZ)
    default lTDZ := false
return StrTran(stringDate, " ", "T") + iif(lTDZ, appData:utc, "")

function ansi_to_unicode(string)
return hmg_ansi_to_unicode(AllTrim(string))

function unicode_to_ansi(string)
return hmg_unicode_to_ansi(mysql_escape_string(AllTrim(string)))
