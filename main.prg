#require "hbwin"
#include "hmg.ch"
#include <fileio.ch>

REQUEST HB_CODEPAGE_UTF8

procedure main
    public appData := TAppData():new("4.0.00")
    public appDataSource
    public appFTP
    public appEmpresas
    public appUsuarios
    public appNuvemFiscal

    // Teste: Em modo de homologação - remover essa variável appQtdeDeTestes de todo o sistema após testes e modo em produção
    public appQtdeDeTestes := 0

    IF HMG SUPPORT UNICODE RUN

    hb_langSelect("PT")
    hb_cdpSelect("UTF8")

    SET CODEPAGE TO UNICODE
    SET LANGUAGE TO PORTUGUESE
    SET MULTIPLE OFF
    SET TOOLTIPSTYLE BALLOON
    SET NAVIGATION EXTENDED
    SET DATE BRITISH
    SET CENTURY ON
    SET EPOCH TO Year(date()) - 20

    appData:registerSystem()

    LOAD WINDOW main
    main.CENTER
    main.ACTIVATE

return

procedure about()
    ShellAbout(;
        "DFeMonitor",;
        "Monitoramento de DFes emitidos pelo sistema web TMS.CLOUD " +;
        appData:version + hb_eol() + Chr(169) + ;
        " by Sistrom Sistemas Web, 2010-" + hb_ntos(year(date())) + " | suporte@sistrom.com.br",;
        LoadTrayIcon(GetInstance(), "main");
    )
return

procedure main_form_oninit()
    local dbServer, dbUser, dbPassword, dbPort, dbDatabase
    local ftpUrl, ftpServer, ftpUser, ftpPassword

    StopTimer()

    if (win_regread(appData:winRegistryPath + "Monitoring\DontRun") == 1)
        saveLog("Parada forçada: O parâmetro DontRun está ativo")
        MessageBoxTimeout("O parâmetro DontRun está ativo!", "Parada forçada", MB_ICONEXCLAMATION, 5000)
        turnOFF()
    endif

    with object appData

        :registerDatabase()

        /*
            Substituição do translado da função RegistryRead pela real função win_regRead()
            Por motivo que eu desconhecido, a função RegistryRead() aqui no main.prg não é
            reconhecida pelo compilador, da erro de compilação, tentei de tudo, o
            #include 'hmg.ch' está ok, tanto que curiosamente a função RegistryWrite() é reconhecida
            pela compilação.
        */
        dbServer := CharXor(win_regread(:winRegistryPath + "Host\db_ServerName"), "SysWeb2023")
        dbUser := CharXor(win_regread(:winRegistryPath + "Host\db_UserName"), "SysWeb2023")
        dbPassword := CharXor(win_regread(:winRegistryPath + "Host\db_Password"), "SysWeb2023")
        dbPort := CharXor(win_regread(:winRegistryPath + "Host\db_Port"), "SysWeb2023")
        dbDatabase := CharXor(win_regread(:winRegistryPath + "Host\db_Database"), "SysWeb2023")

        ftpUrl := CharXor(win_regread(:winRegistryPath + "Host\ftp_url"), "SysWeb2023")
        ftpServer := CharXor(win_regread(:winRegistryPath + "Host\ftp_server"), "SysWeb2023")
        ftpUser := CharXor(win_regread(:winRegistryPath + "Host\ftp_user"), "SysWeb2023")
        ftpPassword := CharXor(win_regread(:winRegistryPath + "Host\ftp_password"), "SysWeb2023")

    endwith

    appDataSource := TMySQLDataSource():new(dbServer, dbUser, dbPassword, dbPort, dbDatabase)
    appFTP := TFtp():new(ftpUrl, ftpServer, ftpUser, ftpPassword)

    if appDataSource:connect()
        appEmpresas := TDbEmpresas():new()
        if !appEmpresas:ok
            saveLog("Nenhuma empresa foi retornada do banco de dados")
            MessageBoxTimeout('Nenhuma empresa foi retornada do banco de dados' + hb_eol() + 'Avise ao suporte!', 'Parada forçada', MB_ICONEXCLAMATION, 300000)
            turnOFF()
        endif
        appUsuarios := TDbUsuarios():new()
        if !appUsuarios:ok
            // A falta de usuários administradores não interfere no monitoramento de CT-es, apenas o Setup não será liberado
            saveLog("Nenhum usuario admin foi retornado do banco de dados")
        endif
    else
        turnOFF()
    endif

    appNuvemFiscal := TNuvemFiscal():new()
    if !appNuvemFiscal:Authorized
        turnOFF()
    endif
    consoleLog({'token: ', appNuvemFiscal:token, hb_eol(), 'Validade: ', appNuvemFiscal:expires_in, hb_eol(), 'Auth: ', appNuvemFiscal:Authorized, hb_eol(), 'RegPath: ', appNuvemFiscal:regPath})
    SetProperty("main", "notifyIcon", "ntfyICON")
    startTimer()

return

// Essa procedure é invodada pelo timer em main.fmg conforme intervalo estabelecido no timer: 10 segundos
procedure main_Timer_dfe_action()
    local timeHHMM := hb_ULeft(Time(), 5)
    local timerStart := appData:timerStart
    local timerEnd := appData:timerEnd

    stopTimer()

    if IsWindowActive(setup)
        appData:setTimer()
        return
    endif

    if (win_regread(appData:winRegistryPath + "Monitorin\Stop_Execution") == 1)
        saveLog("Parada forçada para atualização")
        turnOFF()
    endif

    // timerStart e timerEnd são período de inatividade
    if (timerStart < timerEnd)
        // Inatividade dentro do mesmo dia
        if (timeHHMM >= timerStart) .and. (timeHHMM <= timerEnd)
            // Período de inatividade ativo, não faz monitoramento de CTes/MDFes
            appData:setTimer()
            startTimer()
            return
        endif
    else
        // Inatividade de um dia para o outro
        if (timeHHMM >= timerStart .and. timeHHMM <= "23:59") .or. (timeHHMM >= "00:00" .and. timeHHMM <= timerEnd)
            // Período de inatividade ativo entre antes da meia noite e madrugada, não faz monitoramento de CTes/MDFes
            appData:setTimer()
            startTimer()
            return
        endif
    endif

    // Monitoramento de CTes e MDFes conforme a frequência estabelecida em frequency
    if (Seconds() - appData:timer >= appData:frequency)
        if appQtdeDeTestes < 3
            cteMonitoring()
            mdfeMonitoring()
            appData:setTimer()
            appQtdeDeTestes++
        endif
    endif

    startTimer()

return

procedure turnOFF(isUser)

    default isUser := false
    stopTimer()
    appDataSource:disconnect()

    if isUser
       saveLog('Sistema encerrado pelo usuário')
    else
       saveLog('Sistema encerrou a execução')
    endif
    RegistryWrite(appData:winRegistryPath + "Monitoring\Running", 0)
    RELEASE WINDOW ALL

return
