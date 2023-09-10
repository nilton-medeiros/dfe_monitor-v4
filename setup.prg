#include <hmg.ch>

/*
    Dependências:
        Lib: sistrom_comp (libsistrom_comp.a)
            - TDBGrid
            - TComboBox
*/

procedure setup()
	private grid AS OBJECT
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

	grid := TDBGrid():new('setup', 'Grid_1')
	cbxUsers := TComboBox():new('setup', 'Combo_Users')

    for each empresa in appEmpresas:empresas
        grid:AddItem({empresa:id,;
                        empresa:xNome,;
                        iif(empresa:tpAmb == '1','Produção', 'Homologação')})
    next

    for each usuario in appUsuarios:usuarios
        cbxUsers:AddItem(usuario:login, usuario:password)
    next

    cbxUsers:setValue(1)

    SetProperty('setup', 'Text_seconds', 'Value', appData:frequency)
    SetProperty('setup', 'Text_das', 'Value', appData:timerStart)
    SetProperty('setup', 'Text_as', 'Value', appData:timerEnd)
    SetProperty('setup', 'Text_path_xml_pdf', 'Value', appData:dfePath)
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
	TextBox_onlostfocus("setup", "Text_seconds")
return

procedure setup_text_das_onLostFocus()
	if (GetProperty('setup', 'Text_das', 'Value') < "00:00") .or. (GetProperty('setup', 'Text_das', 'Value') > "23:59")
		SetProperty('setup', 'Text_das', 'Value', '  :  ')
	endif
	TextBox_onlostfocus("setup", "Text_das")
return

procedure setup_text_as_onLostFocus()
	if (GetProperty('setup', 'Text_as', 'Value') < "00:00") .or. (GetProperty('setup', 'Text_as', 'Value') > "23:59")
		SetProperty('setup', 'Text_as', 'Value', '  :  ')
	endif
	TextBox_onlostfocus("setup", "Text_as")
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
        log('Usuario ' + cbxUsers:getDisplay() + ' alterou campos do setup')
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
