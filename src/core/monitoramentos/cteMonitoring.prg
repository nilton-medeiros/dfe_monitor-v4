#include "hmg.ch"

procedure cteMonitoring()
    local cte, dbCTes := TDbCTes():new()

    dbCTes:getListCTes()

    if (dbCTes:count == 0)
        return // Não retornou CTEs para transmitir a Sefaz
    endif

    for each cte in dbCTes:ctes
        switch cte:monitor_action
            case "SUBMIT"
                cteSubmit(cte)
                exit
            case "GETFILES"
                cteGetFiles(TApiCTe():new(cte))
                exit
            case "CANCEL"
                cteCancel(cte)
                exit
            case "CONSULT"
                cteConsult(cte)
                exit
            endswitch
        cte:setUpdateCte('cte_monitor_action', "EXECUTED")
        cte:save()
        cte:saveEventos()
        DO EVENTS
    next

return
