
procedure mdfeUploadFiles(upload)
    local mdfe := upload["mdfe"], empresa := upload["empresa"]
    local upFTP, remotePath := empresa:remote_file_path + "/mdf/files"

    if hb_HGetRef(upload, "pdf")
        upFTP := TGED_FTP():new(upload["pdf"], remotePath)
        if upFTP:upload()
            mdfe:setUpdateMdfe('pdf', upFTP:getURL())
            mdfe:setUpdateEventos("UPLOAD PDF", date_as_DateTime(date(), false, false), "FILE PDF", "Arquivo PDF do DAMDFE carregado com sucesso!")
        else
            mdfe:setUpdateEventos("UPLOAD PDF", date_as_DateTime(date(), false, false), "FILE PDF", "Falha ao carregar Arquivo PDF do DAMDFE, ver log servidor local!")
        endif
    endif

    if hb_HGetRef(upload, "xml")
        upFTP := TGED_FTP():new(upload["xml"], remotePath)
        if upFTP:upload()
            mdfe:setUpdateMdfe('xml', upFTP:getURL())
            mdfe:setUpdateEventos("UPLOAD XML", date_as_DateTime(date(), false, false), "FILE XML", "Arquivo XML do MDFe carregado com sucesso!")
        else
            mdfe:setUpdateEventos("UPLOAD XML", date_as_DateTime(date(), false, false), "FILE XML", "Falha ao carregar Arquivo XML do MDFe, ver log servidor local!")
        endif
    endif

return