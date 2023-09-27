
procedure cadastrarEmpresa(empresa)
    local nuvemFiscal := TApiEmpresas():new()

    if nuvemFiscal:connected
        if nuvemFiscal:Cadastrar(empresa)
            saveLog("Empresa " + empresa:CNPJ + "cadastrada na API Nuvem Fiscal com sucesso!")
        else
            saveLog("Falha ao cadastrar empresa na API Nuvem Fiscal")
            saveLog({;
                "Content-Type: " + nuvemFiscal:ContentType, hb_eol(),;
                "Response: " + nuvemFiscal:response, hb_eol(),;
                "Html Status: " + hb_ntos(nuvemFiscal:responseStatus);
            })
        endif
    else
        saveLog("Falha de conexão com API Nuvem Fiscal!")
    endif

return
