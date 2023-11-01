
procedure mdfeUploadFiles(upload)
    local mdfe := upload["mdfe"], empresa := upload["empresa"]
    local upFTP

    // Debug: Descomentar todas as linhas de upFTP := TGED_FTP() após testes
    consoleLog("Entrou em mdfeUploadFiles")

    if hb_HGetRef(upload, "pdf")
        consoleLog({"FakeTest: Efetuado o upload simbólico do arquivo: ", upload["pdf"]})
        // upFTP := TGED_FTP():new(upload["pdf"], empresa:remote_file_path)
        // if upFTP:upload()
        //     mdfe:setUpdateMdfe('pdf', upFTP:getURL())
        //     mdfe:setUpdateEventos("UPLOAD PDF", date_as_DateTime(date(), false, false), "FILE PDF", "Arquivo PDF do DAMDFE carregado com sucesso!")
        // else
        //     mdfe:setUpdateEventos("UPLOAD PDF", date_as_DateTime(date(), false, false), "FILE PDF", "Falha ao carregar Arquivo PDF do DAMDFE, ver log servidor local!")
        // endif
    endif

    if hb_HGetRef(upload, "xml")
        consoleLog({"FakeTest: Efetuado o upload simbólico do arquivo: ", upload["xml"]})
        // upFTP := TGED_FTP():new(upload["xml"], empresa:remote_file_path)
        // if upFTP:upload()
        //     mdfe:setUpdateMdfe('xml', upFTP:getURL())
        //     mdfe:setUpdateEventos("UPLOAD XML", date_as_DateTime(date(), false, false), "FILE XML", "Arquivo XML do MDFe carregado com sucesso!")
        // else
        //     mdfe:setUpdateEventos("UPLOAD XML", date_as_DateTime(date(), false, false), "FILE XML", "Falha ao carregar Arquivo XML do MDFe, ver log servidor local!")
        // endif
    endif

return