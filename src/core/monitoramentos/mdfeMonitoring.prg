#include "hmg.ch"

procedure mdfeMonitoring()
    local mdfe, dbMDFes := TDbMDFes():new()
    local emTeste := true // Debug: Remover esta linha após testes

    dbMDFes:getListMDFes()

    if (dbMDFes:count == 0)
        return // Não retornou MDFEs para transmitir a Sefaz
    endif

    for each mdfe in dbMDFes:mdfes
        // Debug: Em teste, remover esta variável "emTeste" e o "if emTeste" após testes
        if emTeste
            consoleLog({"Entrou mdfemonitoring, id mdfe: ", mdfe:id, ", invocando mdfeSubmit e mdfeCancel"})
            // Os MDFes de 160 à 165 são dados reais e vem do banco de dados e serao processados no ambiente de homologação
            mdfeSubmit(mdfe)
        else
            switch mdfe:monitor_action
                case "SUBMIT"       // Enviar
                    mdfeSubmit(mdfe)
                    exit
                case "GETFILES"     // Obter arquivos PDF & XML
                    mdfeGetFiles(mdfe)
                    exit
                case "CANCEL"       // Cancelar
                    mdfeCancel(mdfe)
                    exit
                case "CLOSE"        // Encerrar
                    mdfeClose(mdfe)
                    exit
            endswitch

            // cte_monitor_action: Mesmo nome de campo nas tabelas ctes e mdfes
            mdfe:setUpdateMDFe('cte_monitor_action', "EXECUTED")
            mdfe:save()
            mdfe:saveEventos()
        endif
        DO EVENTS
    next

return