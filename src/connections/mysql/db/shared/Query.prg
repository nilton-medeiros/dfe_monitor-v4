#include <hmg.ch>
#include <hbclass.ch>

#define ENCRYPTED .T.

class TQuery

    data db as object readonly
    data sql readonly
    data executed readonly

    method new(cSql) constructor
    method runQuery(sql)
    method serverBusy()
    method Destroy()

end class

method new(cSql) class TQuery
    ::sql := cSql
    ::executed := false
    if appDatabase:connected .or. appDatabase:connect()
        msgNotify({'notifyTooltip' => "Executando query..."})
        if ::runQuery()
            ::db:GoTop()
        endif
        msgNotify()
    endif
return self

method runQuery() class TQuery
    local tenta as numeric
    local msgLog, command, table, mode

    ::db := appDatabase:mysql:Query(::sql)

    if (::db == nil)
        if !appDatabase:connect()
            msgNotify({"notifyTooltip" => "B.D. não conectado!"})
            saveLog("Banco de Dados não conectado!")
            return false
        endif
        ::db := appDatabase:mysql:Query(::sql)
        if (::db == nil)
            msgNotify({'notifyTooltip' => "Erro de SQL!"})
            msgLog := "Erro ao executar Query! [Query is NIL]" + hb_eol() + hb_eol()
            msgLog += ProcName(2) + "(" + hb_ntos(ProcLine(2)) + ")" + hb_eol()
            msgLog += ProcName(1) + "(" + hb_ntos(ProcLine(1)) + ")" + hb_eol()
            msgLog += ProcName(0) + "(" + hb_ntos(ProcLine(0)) + ")" + hb_eol() + hb_eol()
            saveLog(msgLog)
            msgDebugInfo({'Erro ao executar ::db, avise ao suporte!', hb_eol() + hb_eol(), 'Ver Log do sistema', hb_eol(), 'Erro: Query is NIL'})
            return false
        endif
    endif

    if ::serverBusy()
        msgLog := "Servidor do Banco de Dados ocupado, tente mais tarde!" + hb_eol() + hb_eol()
        msgLog += ProcName(2) + "(" + hb_ntos(ProcLine(2)) + ")" + hb_eol()
        msgLog += ProcName(1) + "(" + hb_ntos(ProcLine(1)) + ")" + hb_eol()
        msgLog += ProcName(0) + "(" + hb_ntos(ProcLine(0)) + ")" + hb_eol() + hb_eol()
        saveLog(msgLog)
        msgDebugInfo({'Servidor do Banco de Dados ocupado, tente mais tarde!', hb_eol() + hb_eol(), 'Ver Log do sistema', hb_eol(), ::db:Error()})
        ::db:Destroy()
        return false
    endif

    command := hmg_upper(firstString(hb_utf8StrTran(::db:cQuery, ";")))

    do case
        case command $ "SELECT|DELETE"
            table := hb_USubStr(::db:cQuery, hb_UAt(' FROM ', ::db:cQuery))
            table := firstString(hb_USubStr(table, 7))
            mode := iif(command == "SELECT", "selecionar", "excluir")
        case command == "INSERT"
            table := hb_USubStr(::db:cQuery, hb_UAt(" INTO ", ::db:cQuery))
            table := firstString(hb_USubStr(table, 7))
            mode := "incluir"
        case command == "UPDATE"
            table := hb_USubStr(::db:cQuery, hb_UAt(" ", ::db:cQuery))
            table := firstString(table)
            mode := "incluir"
        otherwise // START, ROOLBACK ou COMMIT
            table := ""
            mode := "executar transação"
    endcase

    if !Empty(table)
        table := Capitalize(table)
    endif

    if ::db:NetErr()
        if ("DUPLICATE ENTRY" $ hmg_upper(::db:Error()))
            saveLog("Erro de duplicidade ao " + mode + " " + table + hb_eol() + ansi_to_unicode(::sql), ENCRYPTED)
        else
            saveLog("Erro ao " + mode + iif(Empty(table), " ", " na tabela de " + table) + hb_eol() + db:Error() +;
                    hb_eol() + hb_eol() + ansi_to_unicode(::db:cQuery), ENCRYPTED)
        endif
        ::db:Destroy()
        msgNotify({'notifyTooltip' => "Rejeição de SQL" + hb_eol() + "Ver Log do sistema"})
    elseif (command $ "SELECT|START|ROOLBACK|COMMIT")
        // Query SELECT Executada com sucesso!
        ::executed := true
        ::db:goTop()
    else
        /* Query INSERT, UPDATE ou DELETE executada com sucesso!
           Verifica se houve algum registro afetado ou não
        */
        if (mysql_affected_rows(::db:nSocket) <= 0)
            saveLog("Não foi possível " + mode + " na tabela de " + table + hb_eol() + "Registros afetados: " +;
                hb_ntos(mysql_affected_rows(::db:nSocket)) + hb_eol() + hb_eol() + mysql_error(::db:nSocket) + hb_eol() + hb_eol() +;
                ansi_to_unicode(::db:cQuery), ENCRYPTED)
            msgNotify({'notifyTooltip' => "Não foi possível " + mode + " na tabela de " + table + hb_eol() + "Ver Log do sistema"})
            ::db:Destroy()
        else
            ::executed := true
        endif
    endif

return ::executed

method serverBusy() class TQuery
return (::db:NetErr() .and. 'server has gone away' $ ::db:Error())

method Destroy() class TQuery
    if !(::db == nil)
        ::db:Destroy()
        ::db := nil
    endif
return self
