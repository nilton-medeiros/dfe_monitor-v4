
procedure cteUploadFiles(upload)
    local cte := upload["cte"], empresa := upload["empresa"]
    local upFTP

    // Debug: Descomentar todas as linhas de upFTP := TGED_FTP() após testes
    consoleLog("Entrou em cteUploadFiles")

    if hb_HGetRef(upload, "pdf")
        consoleLog({"FakeTest: Efetuado o upload simbólico do arquivo: ", upload["pdf"]})
        // upFTP := TGED_FTP():new(upload["pdf"], empresa:remote_file_path)
        // if upFTP:upload()
        //     cte:setUpdateCte('cte_pdf', upFTP:getURL())
        //     cte:setUpdateEventos("UPLOAD PDF", date_as_DateTime(date(), false, false), "FILE PDF", "Arquivo PDF do DACTE carregado com sucesso!")
        // else
        //     cte:setUpdateEventos("UPLOAD PDF", date_as_DateTime(date(), false, false), "FILE PDF", "Falha ao carregar Arquivo PDF do DACTE, ver log servidor local!")
        // endif
    endif

    if hb_HGetRef(upload, "xml")
        consoleLog({"FakeTest: Efetuado o upload simbólico do arquivo: ", upload["xml"]})
        // upFTP := TGED_FTP():new(upload["xml"], empresa:remote_file_path)
        // if upFTP:upload()
        //     cte:setUpdateCte('cte_xml', upFTP:getURL())
        //     cte:setUpdateEventos("UPLOAD XML", date_as_DateTime(date(), false, false), "FILE XML", "Arquivo XML do CTE carregado com sucesso!")
        // else
        //     cte:setUpdateEventos("UPLOAD XML", date_as_DateTime(date(), false, false), "FILE XML", "Falha ao carregar Arquivo XML do CTE, ver log servidor local!")
        // endif
    endif

    if hb_HGetRef(upload, "pdfCancel")
        consoleLog({"FakeTest: Efetuado o upload simbólico do arquivo: ", upload["pdfCancel"]})
        // upFTP := TGED_FTP():new(upload["pdfCancel"], empresa:remote_file_path)
        // if upFTP:upload()
        //     cte:setUpdateCte('cte_cancelado_pdf', upFTP:getURL())
        //     cte:setUpdateEventos("UPLOAD PDF", date_as_DateTime(date(), false, false), "FILE PDF", "Arquivo PDF do CTE CANCELADO carregado com sucesso!")
        // else
        //     cte:setUpdateEventos("UPLOAD PDF", date_as_DateTime(date(), false, false), "FILE PDF", "Falha ao carregar Arquivo PDF do CTE CANCELADO, ver log servidor local!")
        // endif
    endif

    if hb_HGetRef(upload, "xmlCancel")
        consoleLog({"FakeTest: Efetuado o upload simbólico do arquivo: ", upload["xmlCancel"]})
        // upFTP := TGED_FTP():new(upload["xmlCancel"], empresa:remote_file_path)
        // if upFTP:upload()
        //     cte:setUpdateCte('cte_cancelado_xml', upFTP:getURL())
        //     cte:setUpdateEventos("UPLOAD XML", date_as_DateTime(date(), false, false), "FILE XML", "Arquivo XML do CTE CANCELADO carregado com sucesso!")
        // else
        //     cte:setUpdateEventos("UPLOAD XML", date_as_DateTime(date(), false, false), "FILE XML", "Falha ao carregar Arquivo XML do CTE CANCELADO, ver log servidor local!")
        // endif
    endif

return