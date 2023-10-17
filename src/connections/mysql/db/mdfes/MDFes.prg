#include "hmg.ch"
#include <hbclass.ch>

class TDbMDFes
    data mdfes

    method new() constructor
    method count() setget
    method getListMDFes()
    method updateMDFe()

end class

method new() class TDbMDFes
    ::mdfes := {}
return self

method count() class TDbMDFes
return hmg_len(::mdfes)

method getListMDFes() class TDbMDFes
    local hMDFe, dbMDFes, sql := TSQLString():new()

    sql:setValue("SELECT id, ")
    sql:add("emp_id, ")
    sql:add('tpEmit, ')
    sql:add('`mod` AS modelo, ')
    sql:add('serie, ')
    sql:add('nMDF, ')
    sql:add('cMDF as chMDFe, ')
    sql:add('nProt, ')
    sql:add('dhEmi, ')
    sql:add('tpEmis, ')
    sql:add('procEmi, ')
    sql:add('verProc, ')
    sql:add('UFIni, ')
    sql:add('UFFim, ')
    sql:add('qCTe, ')
    sql:add('vCarga, ')
    sql:add('cUnid, ')
    sql:add('qCarga, ')
    sql:add('infAdFisco, ')
    sql:add('infCpl, ')
    sql:add('lista_tomadores, ')
    sql:add('referencia_uuid, ')
    sql:add('nuvemfiscal_uuid, ')
    sql:add('situacao, ')
    sql:add('cte_monitor_action ')
    sql:add('FROM view_mdfes ')

    if (appEmpresas:count == 1)
        // Apenas uma empresa emitente
        empresa := appEmpresas:empresas[1]
        sql:add("WHERE emp_id = " + hb_ntos(empresa:id))
    else
        // Mais de uma empresa emitente
        sql:add("WHERE emp_id IN (")
        primeiro := true
        for each empresa in appEmpresas:empresas
            if !primeiro
                sql:add(",")
            endif
            sql:add(hb_ntos(empresa:id))
            primeiro := false
        next
        sql:add(")")
    endif

    sql:add(" AND cte_monitor_action IN ('SUBMIT','CANCEL','CLOSE') ")
    sql:add("ORDER BY cte_monitor_action, emp_id, nMDF")

    ::mdfes := {}
    dbMDFes := TQuery():new(sql:value)

    if dbMDFes:executed
        do while !dbMDFes:eof()
            hMDFe := convertFieldsDb(dbMDFes:GetRow())
            AAdd(::mdfes, TMDFe():new(hMDFe))
            dbMDFes:Skip()
        enddo
    endif

    dbMDFes:Destroy()

return nil