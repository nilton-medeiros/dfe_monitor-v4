#include <hmg.ch>
#include <hbclass.ch>

class TDbUsuarios
    data usuarios
    data ok
    method new() constructor
    method count() setget inline hmg_len(::usuarios)
end class

method new() class TDbUsuarios
    local dbUsers, sql := TSQLString():new()
    local hRow

    sql:setValue("SELECT user_id as id, ")
    sql:add("user_login AS login, ")
    sql:add("user_senha AS password ")
    sql:add("FROM view_usuarios ")
    sql:add("WHERE user_ativo = TRUE AND perm_grupo = 'Administradores' ")
    sql:add("ORDER BY user_id")

    ::usuarios := {}
    ::ok := false
    dbUsers := TQuery():new(sql:value)

    if :executed
        with object dbUsers
            do while !:db:Eof()
               hRow := convertFieldsDb(:db:GetRow())
               AAdd(::usuarios, TUsuario():new(hRow))
               :db:Skip()
            enddo
        endwith
    endif

    ::ok := !(hmg_len(::usuarios) == 0)
    dbUsers:Destroy()

return self