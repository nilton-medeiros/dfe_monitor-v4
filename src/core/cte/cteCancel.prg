#include "hmg.ch"

procedure cteCancel(cte)
    local apiCTe := TApiCTe():new(cte)
    local startTimer, recebido, cancelado
    local targetFile, anoEmes, directory, aError, error

    recebido := apiCTe:Cancelar()
    cancelado := false

    if recebido

        consoleLog("Processando Cancelar(cte) | apiCTe:status " + apiCTe:status)   // Debug

        // Se CTe foi recebido, verifica se foi cancelado, rejeitado ou se ainda está pendente (aguardando na fila para ser processado)
        cancelado := (apiCTe:status == "cancelado")

        if !cancelado

            // Normalmente em produção a api da Nuvem Fiscal retorna status "pendente" segundo orientação da nv, nos testes (homologação) retornaram direto 'cancelado'
            sysWait(2)  // Aguarda 2 segundos para obter autorizado ou erro

            startTimer := Seconds()

            do while apiCTe:Consultar() .and. (apiCTe:status == 'pendente') .and. (Seconds() - startTimer < 10)
                // Situação pouco provável, porem não impossível: Insiste obter informações por até 10 segundos
                sysWait(2)
            enddo

            cancelado := (apiCTe:status == "cancelado")
            consoleLog("Cancelado: " + iif(cancelado, "SIM", "NÃO"))  // Debug

        endif

        if cancelado

            // Prepara os campos da tabela ctes para receber os updates
            cte:setSituacao(apiCTe:status)

            // Prepara os campos da tabela ctes_eventos para receber os updates
            if !Empty(apiCTe:motivo_status)
                cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_evento, apiCTe:codigo_status, apiCTe:motivo_status)
            endif
            if !Empty(apiCTe:mensagem)
                cte:setUpdateEventos(apiCTe:numero_protocolo, apiCTe:data_recebimento, apiCTe:codigo_mensagem, apiCTe:mensagem)
            endif

        endif

    endif

    if !cancelado
        aError := getMessageApiError(apiCTe, false)
        for each error in aError
            cte:setUpdateEventos("Erro", date_as_DateTime(date(), false, false), error["code"], error["message"])
        next
        cte:setSituacao("ERRO")
        // Debug
        consoleLog("apiCTe:response" + apiCTe:response + hb_eol() + "API Conectado: " + iif(apiCTe:connected, "SIM", "NÃO"))
    endif

    if cancelado
        cteGetFiles(cte)
    endif

return
