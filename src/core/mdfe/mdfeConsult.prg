#include "hmg.ch"

procedure mdfeConsult(mdfe)
    local apiMDFe := TApiMDFe():new(mdfe)
    local aError, error

    if apiMDFe:Consultar()

        // Prepara os campos da tabela mdfes para receber os updates
        mdfe:setSituacao(apiMDFe:status)
        mdfe:setUpdateMDFe('cMDF', apiMDFe:chave_acesso)
        mdfe:setUpdateMDFe('digest_value', apiMDFe:digest_value)
        mdfe:setUpdateMDFe('nProt', apiMDFe:numero_protocolo)
        mdfe:setUpdateMDFe('nuvemfiscal_uuid', apiMDFe:nuvemfiscal_uuid)

        // Prepara os campos da tabela mdfes_eventos para receber os updates
        if !Empty(apiMDFe:motivo_status)
            mdfe:setUpdateEventos(apiMDFe:numero_protocolo, apiMDFe:data_evento, apiMDFe:codigo_status, apiMDFe:motivo_status)
        endif
        if !Empty(apiMDFe:mensagem)
            mdfe:setUpdateEventos(apiMDFe:numero_protocolo, apiMDFe:data_recebimento, apiMDFe:codigo_mensagem, apiMDFe:mensagem)
        endif

        mdfeGetFiles(mdfe, apiMDFe)

    else

        aError := getMessageApiError(apiMDFe, false)
        for each error in aError
            mdfe:setUpdateEventos("Erro", date_as_DateTime(date(), false, false), error["code"], error["message"])
        next
        mdfe:setSituacao("ERRO")

    endif

return