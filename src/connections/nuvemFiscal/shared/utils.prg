// Função compartilhada entre as classes API Nuvem Fiscal para obter uma conexão MSXML2 objeto OLE

function GetMSXMLConnection()
	local connection

    begin sequence
        connection := win_oleCreateObject("MSXML2.ServerXMLHTTP.6.0")
        if Empty(connection)
            saveLog("Erro na criação do serviço: MSXML2")
            consoleLog({'win_oleCreateObject("MSXML2.ServerXMLHTTP.6.0") retornou type: ', ValType(connection), hb_eol()})
            Break
        endif
    end sequence

return connection


// Função utilizada para obter resposta de erros retornados, deve ser refatorada para ler o array de errors
function getMessageApiError(api, lAsText)
	local response, textError := "", aError := {}, error, n := 0

	default lAsText := true

	if api:ContentType == "json"
		consoleLog(api:response)
		response := hb_jsonDecode(api:response)
		if hb_HGetRef("errors")
			response := response["errors"]
			for each error in response
				AAdd(aError, error)
			next
		else
			AAdd(aError, response["error"])
		endif
		if lAsText
			for each error in aError
				if (++n > 1)
					textError += hb_eol()
				endif
				textError += "Código: " + error["code"] + hb_eol()
				textError += "Menssagem: " + error["message"]
			next
		endif
	else
		if lAsText
			textError := api:response
		else
			AAdd(aError, {"code" => "sem código", "message" => api:response})
		endif
	endif


return iif(lAsText, textError, aError)
