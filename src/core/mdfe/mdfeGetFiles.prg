#include "hmg.ch"

function mdfeGetFiles(apiMDFe)
    local upload := {=>}
    local lFileExists := false
    local directory, filePDF, fileXML, status := ""
    local empresa, anoMes, printPath, printPDF
    local mdfe := apiMDFe:mdfe

    default apiMDFe := TApiMDFe():new(mdfe)

    // Debug
    consoleLog("Entrou em mdfeGetFiles()")

    // As vars que começam com "app" são de nível global (Public) definidas no main.prg
    empresa := appEmpresas:getEmpresa(mdfe:emp_id)

    // "2019-08-24T14:15:22Z"
    anoMes := Left(getNumbers(mdfe:dhEmi), 6)
    directory := appData:dfePath + empresa:CNPJ + '\MDFe\' + anoMes + '\'

    if (mdfe:situacao == "AUTORIZADO")
        status := "-mdfe"
    else
        status := "-mdfe" + Capitalize(mdfe:situacao)
    endif

    filePDF := mdfe:chMDFe + status + ".pdf"
    fileXML := mdfe:chMDFe + status + ".xml"

    if hb_DirExists(directory)
        lFileExists := hb_FileExists(directory + filePDF) .and. hb_FileExists(directory + fileXML)
        if lFileExists
            upload["pdf"] := directory + filePDF
            upload["xml"] := directory + fileXML
        endif
    else
        hb_DirBuild(directory)
    endif

    if !lFileExists

        if apiMDFe:BaixarPDFdoDAMDFE()
            if hb_MemoWrit(directory + filePDF, apiMDFe:pdf_binary)
                upload["pdf"] := directory + filePDF
                saveLog("Arquivo PDF do DAMDFE salvo com sucesso: " + directory + filePDF)
            else
                mdfe:setUpdateEventos("OBTER PDF", date_as_DateTime(date(), false, false), "PDF", "Erro ao escrever PDF em arquivo. Ver log servidor local")
                saveLog("Erro ao escrever pdf binary em arquivo " + filePDF + " na pasta " + directory)
            endif
        else
            mdfe:setUpdateEventos("OBTER PDF", date_as_DateTime(date(), false, false), "PDF", "Arquivo PDF do DAMDFE não retornado. Ver log servidor local")
            saveLog("Arquivo PDF do DAMDFE não retornado; Chave MDFe: " + apiMDFe:chave_acesso)
        endif

        if apiMDFe:BaixarXMLdoMDFe()
            if hb_MemoWrit(directory + fileXML, apiMDFe:xml_binary)
                upload["xml"] := directory + fileXML
                saveLog("Arquivo XML do MDFe salvo com sucesso: " + directory + fileXML)
            else
                mdfe:setUpdateEventos("OBTER XML", date_as_DateTime(date(), false, false), "XML", "Erro ao escrever XML em arquivo. Ver log servidor local")
                saveLog("Erro ao escrever xml binary em arquivo " + fileXML + " na pasta " + directory)
            endif
        else
            mdfe:setUpdateEventos("OBTER XML", date_as_DateTime(date(), false, false), "XML", "Arquivo XML do MDFe não retornado. Ver log servidor local")
            saveLog("Arquivo XML do MDFe não retornado; Chave MDFe: " + apiMDFe:chave_acesso)
        endif

    endif

    if !Empty(upload)
        printPath := RegistryRead("HKEY_CURRENT_USER\Software\Sistrom\SendToPrinter\InstallPath\Path")
        if !Empty(printPath)
            printPath += "printNow\"
            if hb_HGetRef(upload, "pdf")
                printPDF := printPath + Token(upload["pdf"], "\")
                hb_FCopy(upload["pdf"], printPDF)
            endif
        endif
        upload["mdfe"] := mdfe
        upload["empresa"] := empresa
        mdfeUploadFiles(upload)
    endif

return