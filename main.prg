#require "hbwin"
#include "hmg.ch"
#include <fileio.ch>

REQUEST HB_CODEPAGE_UTF8

/*
    DFe_Monitor: Roda como um serviço minimizado na taskbar do Windows, monitora os DFes de um grupo de empresas
                 transportadoras para emitir CTes (4.00) e MDFes, faz Autorização, Cancelamento, Carta de Correção e
                 obtem XMLs/PDFs junto a Rest API da Nuvem Fiscal. Gera DACTE em PDF com layout mais apresentável.
    main: Inicializa o programa, mas é na main_form_oninit() que realmente faz toda a configuração inicial.
        * Todas os objetos públicos começam com "app", são utilizados em toda a aplicação
        appData:        Contém configurações gerais e iniciais da aplicação, cria e atualiza o RegEdit do Windows.
        appDataSource:  Utilizada em qualquer rotina que necessite se conectar ao backend (banco de dados).
        appFTP:         Utilizada pelas rotinas de GED (Gerenciamento Eletrônico de Documentos),
                        faz upload e download de arquivos como xml/pdf,etc de<->para nuvem (S3/Locaweb/etc).
        appEmpresas:    Recebe todas as empresas emitentes de CTe/MDFe na inicialização do aplicativo.
        appUsuarios:    Recebe todos os usuários admin de cada empresa que podem alterar parâmetros de monitoração
                        e outras configurações no form setup do aplicaitvo.
        appNuvemFiscal: Faz a autenticação e disponibiliza integração com a RestAPI da Nuvem Fiscal
*/
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

    // Paraliza o timer de monitoramento enquanto faz as configurações iniciais
    StopTimer()

    if (win_regread(appData:winRegistryPath + "Monitoring\DontRun") == 1)
        saveLog("Parada forçada: O parâmetro DontRun está ativo")
        MessageBoxTimeout("O parâmetro DontRun está ativo!", "Parada forçada", MB_ICONEXCLAMATION, 5000)
        turnOFF()
    endif

    with object appData

        :registerDatabase()

        /*
            Substituição do translado da função RegistryRead() pela real função win_regRead()
            Por motivo que eu desconheço, a função RegistryRead() aqui no main.prg, nesta aplicação não é
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

    appNuvemFiscal := TAuthNuvemFiscal():new()
    if !appNuvemFiscal:Authorized
        turnOFF()
    endif
    // Teste: Passou! | consoleLog({'token: ', appNuvemFiscal:token, hb_eol(), 'Validade: ', appNuvemFiscal:expires_in, hb_eol(), 'Auth: ', appNuvemFiscal:Authorized, hb_eol()})
    SetProperty("main", "notifyIcon", "ntfyICON")
    startTimer()

return

// Monitoramento: Essa procedure é invodada pelo timer em main.fmg conforme intervalo estabelecido no timer: 10 segundos
procedure main_Timer_dfe_action()
    local timeHHMM := hb_ULeft(Time(), 5)
    local timerStart := appData:timerStart
    local timerEnd := appData:timerEnd

    /*
        Paraliza o Timer do form principal main para que as rotinas de monitoramento não
        não sejam chamadas novamente (encavale) enquanto elas estão em execução, o tempo de execução
        depende da quantidade de CTes e MDFes a serem processados
    */
    stopTimer()

    if IsWindowActive(setup)
        appData:setTimer()
        return
    endif

    if (win_regread(appData:winRegistryPath + "Monitorin\Stop_Execution") == 1)
        saveLog("Parada forçada para atualização")
        turnOFF()
    endif

    // timerStart e timerEnd são período de inatividade definido pelos usuários admins em setup form
    if (timerStart < timerEnd)
        // Inatividade dentro do mesmo dia
        if (timeHHMM >= timerStart) .and. (timeHHMM <= timerEnd)
            // Período de inatividade ativo, não faz monitoramento de CTes/MDFes
            appData:setTimer()  // Reseta o timer para mais 10 segundos...
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
        if appQtdeDeTestes < 3  // Remover este if após testes, limita até 3 testes por execução
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
