#include "hmg.ch"
#include "hbclass.ch"

// TFtp Class: Apenas uma sacola de dados, classe anêmica funcionando mais como uma interface

class TFtp
    data url readonly
    data server readonly
    data user readonly
    data password readonly
    method new(url, server, user, password) constructor
end class

method new(url, server, user, password) class TFtp
    ::url := iif(ValType(url) == "C", AllTrim(url), "")
    ::server := iif(ValType(server) == "C", AllTrim(server), "")
    ::user := iif(ValType(user) == "C", AllTrim(user), "")
    ::password := iif(ValType(password) == "C", password, "")
return self
