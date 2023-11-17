#include "hmg.ch"

procedure cteSubmit(cte)
    local apiCTe := TApiCTe():new(cte)
    local startTimer, emitido
    local targetFile, anoEmes, directory, aError, error

    // Refatorado, na versão CTe 4.00 a transmissão é sincrono, já é retornado a autorização ou rejeição

    if apiCTe:Emitir()

        // Prepara os campos da tabela ctes para receber os updates
        cte:setSituacao(apiCTe:status)
        cte:setUpdateCte('cte_chave', apiCTe:chave)
        cte:setUpdateCte('cte_protocolo_autorizacao', apiCTe:numero_protocolo)
        cte:setUpdateCte('nuvemfiscal_uuid', apiCTe:nuvemfiscal_uuid)

        // Prepara os campos da tabela ctes_eventos para receber os updates
        if !Empty(apiCTe:motivo_status)
            cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, apiCTe:codigo_status, apiCTe:motivo_status)
        endif
        if !Empty(apiCTe:mensagem)
            cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_recebimento, apiCTe:codigo_mensagem, apiCTe:mensagem)
        endif

        cteGetFiles(cte, apiCTe)

    else

        aError := getMessageApiError(apiCTe, false)
        for each error in aError
            cte:setUpdateEventos("Erro", date_as_DateTime(date(), false, false), error["code"], error["message"])
        next
        cte:setSituacao("ERRO")

    endif

return
