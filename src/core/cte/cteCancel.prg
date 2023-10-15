#include "hmg.ch"

procedure cteCancel(cte)
    local apiCTe := TApiCTe():new(cte)
    local registrado
    local targetFile, anoEmes, directory, aError, error

    // Debug:
    consoleLog({"Cancelando CTe: ", cte:chave, ", nuvemfiscal_uuid: ", cte:nuvemfiscal_uuid})

    if apiCTe:Cancelar()

        consoleLog("Evento de Cancelamento Registrado | apiCTe:status " + apiCTe:status)   // Debug

        // Prepara os campos da tabela ctes para receber os updates
        if (apiCTe:codigo_status == 135)
            cte:setSituacao("CANCELADO")
            // Debug:
            consoleLog({"CTe: ", apiCTe:chave, " cancelado com sucesso, pegando PDF e XML de Cancelamento"})
            cteGetFiles(cte)
        else
            cte:setSituacao(apiCTe:status)
        endif

        // Prepara os campos da tabela ctes_eventos para receber os updates
        if !Empty(apiCTe:motivo_status)
            cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, apiCTe:codigo_status, apiCTe:motivo_status)
        endif
        if !Empty(apiCTe:mensagem)
            cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_recebimento, apiCTe:codigo_mensagem, apiCTe:mensagem)
        endif

    else
        aError := getMessageApiError(apiCTe, false)
        for each error in aError
            cte:setUpdateEventos("Erro", date_as_DateTime(date(), false, false), error["code"], error["message"])
        next
        cte:setSituacao(apiCTe:status)
        // Debug:
        consoleLog("Erro ao cancelar: apiCTe:response" + apiCTe:response)
    endif

return
