#include "hmg.ch"

procedure cteSubmit(cte)
    local apiCTe := TApiCTe():new(cte)
    local startTimer, recebido, emitido, empresa
    local targetFile, anoEmes, directory, aError, error

    recebido := apiCTe:Emitir()
    emitido := false

    if recebido

        consoleLog("Processando Emitir(cte) | apiCTe:status " + apiCTe:status)   // Debug

        // Se CTe foi recebido, verifica se foi autorizado, rejeitado ou se ainda está pendente (aguardando na fila para ser processado)
        emitido := (apiCTe:status == "autorizado")

        if !emitido

            // Normalmente em produção a api da Nuvem Fiscal retorna status "pendente" segundo orientação da nv, nos testes (homologação) retornaram direto 'autorizado'
            sysWait(2)  // Aguarda 2 segundos para obter autorizado ou erro

            startTimer := Seconds()

            do while apiCTe:Consultar() .and. (apiCTe:status == 'pendente') .and. (Seconds() - startTimer < 10)
                // Situação pouco provável, porem não impossível: Insiste obter informações por até 10 segundos
                sysWait(2)
            enddo

            emitido := (apiCTe:status == "autorizado")
            consoleLog("emitido: " + iif(emitido, "SIM", "NÃO"))  // Debug

        endif

        if emitido

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

        endif

    endif

    if !emitido
        aError := getMessageApiError(apiCTe, false)
        for each error in aError
            cte:setUpdateEventos("Erro", date_as_DateTime(date(), false, false), error["code"], error["message"])
        next
        cte:setSituacao("ERRO")
        // Debug
        consoleLog("apiCTe:response" + apiCTe:response + hb_eol() + "API Conectado: " + iif(apiCTe:connected, "SIM", "NÃO"))
    endif

    if emitido
        cteGetFiles(cte)
    endif

return
