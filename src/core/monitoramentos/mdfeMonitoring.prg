#include "hmg.ch"

procedure mdfeMonitoring()
    local mdfe, dbMDFes := TDbMDFes():new()

    dbMDFes:getListMDFes()

    if (dbMDFes:count == 0)
        return // Não retornou MDFEs para transmitir a Sefaz
    endif

    for each mdfe in dbMDFes:mdfes
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
            case "CONSULT"
                mdfeConsult(mdfe)
                exit
        endswitch

        // cte_monitor_action: Mesmo nome de campo nas tabelas ctes e mdfes
        mdfe:setUpdateMDFe('cte_monitor_action', "EXECUTED")
        mdfe:save()
        mdfe:saveEventos()
        DO EVENTS
    next

return