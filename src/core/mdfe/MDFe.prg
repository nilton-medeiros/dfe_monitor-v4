#include "hmg.ch"
#include "hbclass.ch"

class TMDFe
    data id         // id do MDFe no sistema TMS.Cloud
    data emp_id
    data emitente
    data tpEmit
    data mod
    data serie
    data nMDF
    data cMDF
    data nProt
    data dhEmi
    data tpEmis
    data procEmi
    data verProc
    data UFIni
    data UFFim
    data qCTe
    data vCarga
    data cUnid
    data qCarga
    data infAdFisco
    data infCpl
    data lista_tomadores
    data situacao
    data cte_monitor_action
    data referencia_uuid
    data nuvemfiscal_uuid
    data updateMDFe
    data updateEvents

    method new(mdfe) constructor
    method setSituacao(mdfeStatus)
    method setUpdateMDFe(key, value)
    method setUpdateEventos(protocolo, data_hora, evento, detalhe)

end class

method new(mdfe) class TMDFe

    ::id := mdfe["id"]
    ::emp_id := mdfe["emp_id"]
    ::emitente := appEmpresas:getEmpresa(::emp_id)
    ::tpEmit := mdfe["tpEmit"]
    ::mod := mdfe["modelo"]
    ::serie := mdfe["serie"]
    ::nMDF := mdfe["nMDF"]
    ::cMDF := mdfe["chMDFe"]
    ::nProt := mdfe["nProt"]
    ::dhEmi := mdfe["dhEmi"]
    ::tpEmis := mdfe["tpEmis"]
    ::procEmi := mdfe["procEmi"]
    ::verProc := mdfe["verProc"]
    ::UFIni := mdfe["UFIni"]
    ::UFFim := mdfe["UFFim"]
    ::qCTe := mdfe["qCTe"]
    ::vCarga := mdfe["vCarga"]
    ::cUnid := mdfe["cUnid"]
    ::qCarga := mdfe["qCarga"]
    ::infAdFisco := mdfe["infAdFisco"]
    ::infCpl := mdfe["infCpl"]
    ::lista_tomadores := mdfe["lista_tomadores"]
    ::situacao := mdfe["situacao"]
    ::cte_monitor_action := mdfe["cte_monitor_action"]
    ::referencia_uuid := mdfe["referencia_uuid"]
    ::nuvemfiscal_uuid := mdfe["nuvemfiscal_uuid"]
    ::updateMDFe := {}
    ::updateEvents := {}

return self

method setSituacao(mdfeStatus) class TMDFe
    local lSet := false
    mdfeStatus := hmg_lower(mdfeStatus)
    if !Empty(mdfeStatus) .and. mdfeStatus $ "pendente,autorizado,rejeitado,denegado,encerrado,cancelado,erro"
        ::situacao := hmg_upper(mdfeStatus)
        lSet := true
        ::setUpdateMDFe("mdfe_situacao", ::situacao)
    endif
return lSet

method setUpdateMDFe(key, value) class TMDFe
    local lSet := false, pos

    if !Empty(key)
        pos := hb_ASCan(::updateMDFe, {|hField| hField["key"] == key})
        if (pos == 0)
            AAdd(::updateMDFe, {"key" => key, "value" => value})
        else
            ::updateMDFe[pos]["value"] := value
        endif
        lSet := true
    endif

return lSet

method setUpdateEventos(protocolo, data_hora, evento, detalhe) class TMDFe
    local ambiente := iif((::emitente:tpAmb == 1), "Produção", "Homologação")
    AAdd(::updateEvents, {"mdfe_id" => hb_ntos(::id), ;
                           "protocolo" => cte_ev_protocolo, ;
                           "data_hora" => data_hora, ;
                           "evento" => evento, ;
                           "detalhe" => "Ambiente: " + ambiente + " |" + detalhe})
return nil
