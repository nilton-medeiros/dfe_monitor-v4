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
function getMessageApiError(api)
	local response, msgError

	if api:ContentType == "json"
		consoleLog(api:response)
		response := hb_jsonDecode(api:response)
		msgError := "codigo: " + response['error']['code'] + hb_eol()
		msgError += "Menssagem: " + response['error']['message']
	else
		msgError := api:response
	endif
	saveLog(msgError)
return msgError
