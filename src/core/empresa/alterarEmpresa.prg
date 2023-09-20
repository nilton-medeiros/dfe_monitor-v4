
procedure alterarEmpresa(empresa)
    local nuvemFiscal := TApiEmpresas():new()

    if nuvemFiscal:connected
        if nuvemFiscal:Alterar(empresa)
            saveLog("Empresa " + empresa:CNPJ + " alterada na API Nuvem Fiscal com sucesso!")
            empresa:update()
        else
            saveLog("Falha ao alterar empresa na API Nuvem Fiscal")
            saveLog({;
                "Content-Type: " + nuvemFiscal:responseType, hb_eol(),;
                "Response: " + nuvemFiscal:response, hb_eol(),;
                "Html Status: " + hb_ntos(nuvemFiscal:responseStatus);
            })
        endif
    else
        saveLog("Falha de conexão com API Nuvem Fiscal!")
    endif

return
