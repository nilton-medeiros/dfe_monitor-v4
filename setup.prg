#include "hmg.ch"

procedure setup()
	private cbxUsers AS OBJECT

	if isWindowActive(setup)
		doMethod('setup', 'setFOCUS')
	else
		LOAD WINDOW setup
		ON KEY ESCAPE OF setup ACTION setup.RELEASE
		setup.CENTER
		setup.ACTIVATE
	endif
return

procedure setup_form_oninit()
	local empresa AS OBJECT
	local usuario AS HASH
	local notifyTooltip := hb_utf8StrTran(appData:lastMessage, hb_eol(), " | ")
	local tmp

    stopTimer()

	DoMethod( 'setup', 'Grid_Empresas', "DeleteAllItems" )

    for each empresa in appEmpresas:empresas
		DoMethod('setup', 'Grid_Empresas', "AddItem", {empresa:id, empresa:xNome, iif(empresa:tpAmb == '1','Produção', 'Homologação')})
    next

	SetProperty('setup', 'Tab_Setup', 'value', 1)
	SetProperty('setup', 'Grid_Empresas', 'value', 1)

	cbxUsers := TComboBox():new('setup', 'Combo_Users')

    for each usuario in appUsuarios:usuarios
        cbxUsers:AddItem(usuario:login, usuario:password)
    next

    cbxUsers:setValue(1)

    SetProperty('setup', 'Text_seconds', 'Value', appData:frequency)
    SetProperty('setup', 'Text_das', 'Value', appData:timerStart)
    SetProperty('setup', 'Text_as', 'Value', appData:timerEnd)
    SetProperty('setup', 'Text_path_xml_pdf', 'Value', appData:dfePath)
	SetProperty("setup", "ProgressBar_Transmitindo", "visible", false)
	SetProperty("setup", "ProgressBar_Transmitindo", "enabled", false)
	SetProperty("setup", "ProgressBar_Transmitindo", "value", 50)
	SetProperty("setup", "StatusBar", "Item", 1, "Database: " + appDataSource:database + " | " + notifyTooltip)
    SetProperty("setup", "StatusBar", "Item", 2, appDataSource:connectionStatus)
    SetProperty("setup", "StatusBar", "Icon", 2, appDataSource:iconStatus)


return

procedure showPassword_action()
		SetProperty('setup', 'Label_showPassword', 'Value', GetProperty('setup', 'Text_Password', 'Value'))
		SetProperty('setup', 'Label_showPassword', 'Visible', true)
		Inkey(2)
		SetProperty('setup', 'Label_showPassword', 'Visible', false)
return

procedure setup_text_seconds_onLostFocus()
	if (GetProperty('setup', 'Text_seconds', 'Value') < 5)
		SetProperty('setup', 'Text_seconds', 'Value', 5)
	endif
	TextBox_onLostFocus("setup", "Text_seconds")
return

procedure setup_text_das_onLostFocus()
	if (GetProperty('setup', 'Text_das', 'Value') < "00:00") .or. (GetProperty('setup', 'Text_das', 'Value') > "23:59")
		SetProperty('setup', 'Text_das', 'Value', '  :  ')
	endif
	TextBox_onLostFocus("setup", "Text_das")
return

procedure setup_text_as_onLostFocus()
	if (GetProperty('setup', 'Text_as', 'Value') < "00:00") .or. (GetProperty('setup', 'Text_as', 'Value') > "23:59")
		SetProperty('setup', 'Text_as', 'Value', '  :  ')
	endif
	TextBox_onLostFocus("setup", "Text_as")
return

procedure setup_button_save_action()
	local dfePath := GetProperty('setup', 'Text_path_xml_pdf', 'Value')

    if empty(dfePath)
		MsgExclamation('Definir a pasta raiz dos XMLs & PDFs')
        return
    endif
	if !hb_DirExists(dfePath) .and. !hb_DirBuild(dfePath)
		MsgExclamation('Pasta raiz inválida, não pode ser criada')
        return
	endif

	if GetProperty('setup', 'Text_seconds', 'Value') < 10
		SetProperty('setup', 'Text_seconds', 'Value', 10)
	endif

    if (GetProperty('setup', 'Text_password', 'Value') == cbxUsers:getCargo())
        appData:dfePath := dfePath
        RegistryWrite(appData:registryPath + "InstallPath\dfePath", dfePath)
        RegistryWrite(appData:registryPath + "Monitoring\TimerStart", GetProperty('setup', 'Text_das', 'Value'))
        RegistryWrite(appData:registryPath + "Monitoring\TimerEnd", GetProperty('setup', 'Text_as', 'Value'))
        RegistryWrite(appData:registryPath + "Monitoring\frequency", GetProperty('setup', 'Text_seconds', 'Value'))
        saveLog('Usuario ' + cbxUsers:getDisplay() + ' alterou campos do setup')
        doMethod('setup', 'RELEASE')
	else
		MsgExclamation('Senha Inválida para o usuário ' + cbxUsers:getDisplay() + "!", 'Senha')
	endif

return

procedure setup_button_cancel_action()
	doMethod('setup', 'RELEASE')
return

procedure setup_button_turnOFF_action()
	if MsgYesNo("Deseja interromper o monitoramento de DFEs?", 'DFeMonitor: Desligar')
		turnOFF(true)
	endif
return

procedure setup_form_onrelease()
	startTimer()
return

procedure setup_Grid_Empresas_onChange()
	local index := GetProperty("setup", "Grid_Empresas", "value")
	local empresa

	if !(index == 0)
		empresa :=  appEmpresas:empresas[index]
		with object empresa
			SetProperty('setup', 'Text_RazaoSocial', 'value', :xNome)
			SetProperty('setup', 'Text_CNPJ', 'value', :CNPJ)
		endwith
	endif

return

procedure setup_button_arquivopfx_action()
	local filePFX := GetFile({{'Arquivos PFX (*.pfx)', '*.pfx'}, {'Arquivos P12 (*.p12)', '*.p12'}}, 'Selecione o Certificado', 'certificados')
	SetProperty('setup', 'Text_ArquivoPFX', 'value', filePFX)
return

procedure setup_button_Submit_action()
	local cnpj := GetProperty('setup', 'Text_CNPJ', 'value')
	local filePFX := GetProperty('setup', 'Text_ArquivoPFX', 'value')
	local paswPFX := GetProperty('setup', 'Text_SenhaPFX', 'value')
	local paswUser := GetProperty('setup', 'Text_password', 'Value')
	local certificado, cdEncode64, fileLoaded, tudoCerto
	local hResponse, jsonResponse, periodoValidade, msgRetorno

	SetProperty('setup', 'Label_StatusPFX', 'value', '')

	if Empty(filePFX)
		MsgExclamation("Arquivo PFX não podem estar vazios!", "Arquivo PFX (Certificado A1)")
	elseif  Empty(paswPFX)
		MsgExclamation("Senha do certificado A1 inválida!", "Senha (Certificado A1)")
	elseif !hb_FileExists(filePFX)
		MsgExclamation("Arquivo " + filePFX + hb_eol() + "não encontrado!", "Arquivo PFX (Certificado A1)")
	elseif !(paswUser == cbxUsers:getCargo())
		MsgExclamation("Senha do admin inválida!" + hb_eol() + "Verifique na primeira guia (Configurações) se você digitou a senha correta do usuário selecionado.", "Senha")
	elseif Empty(cnpj)
		MsgExclamation("Selecione a empresa na grade da guia Configurações!", "Selecione uma Empresa")
	else
		// Submeter a Nuvem Fiscal e obter resposta
		SetProperty('setup', 'Label_StatusPFX', 'value', 'Carregando...')
		SetProperty('setup', 'Label_StatusPFX', 'visible', true)
		SetProperty("setup", "ProgressBar_Transmitindo", "visible", true)
		SetProperty("setup", "ProgressBar_Transmitindo", "enabled", true)
		SET PROGRESSBAR ProgressBar_Transmitindo OF setup ENABLE MARQUEE UPDATED 10

		// Transmitir para a nuvem fiscal e pegar retorno
		fileLoaded := hb_MemoRead(filePFX)
		cdEncode64 := HB_Base64Encode(fileLoaded)
		certificado := TApiCertificado():new(cnpj)
		tudoCerto := certificado:Cadastrar(cdEncode64, paswPFX)

		if tudoCerto
			jsonResponse := jsonDecode(certificado:response)
			SetProperty('setup', 'Text_RazaoSocial', 'value', jsonResponse['nome_razao_social'])
			SetProperty('setup', 'Text_Assunto', 'value', jsonResponse['subject_name'])
			SetProperty('setup', 'Text_Emissor', 'value', jsonResponse['issuer_name'])
			SetProperty('setup', 'Text_Serie', 'value', jsonResponse['serial_number'])

			// 2019-08-24T14:15:22Z
			periodoValidade := Left(StrTran(jsonResponse['not_valid_before'], "T", " "), 19)
			periodoValidade += " à " + Left(StrTran(jsonResponse['not_valid_after'], "T", " "), 19)
			SetProperty('setup', 'Text_Validade', 'value', periodoValidade)
		else
			if certificado:ContentType == "json"
				consoleLog(certificado:response)
				jsonResponse := jsonDecode(certificado:response)
				msgRetorno := "codigo: " + jsonResponse['error']['code'] + hb_eol()
				msgRetorno += "Menssagem: " + jsonResponse['error']['message']
			else
				msgRetorno := certificado:response
			endif
			saveLog(msgRetorno)
		endif

		SET PROGRESSBAR ProgressBar_Transmitindo OF setup DISABLE MARQUEE
		SetProperty("setup", "ProgressBar_Transmitindo", "enabled", false)
		SetProperty("setup", "ProgressBar_Transmitindo", "visible", false)

		if tudoCerto
			SetProperty('setup', 'Label_StatusPFX', 'value', 'Certificado carregado com sucesso!')
		else
			SetProperty('setup', 'Label_StatusPFX', 'value', 'Erro ao carregar Certificado!')
			SetProperty('setup', 'Label_StatusPFX', 'FontColor', {255,0,0})
			MsgStop(msgRetorno, "Erro ao carregar Certificado A1")
		endif

	endif

return