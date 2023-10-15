#include "hmg.ch"

function cteGetFiles(cte, apiCTe)
    local lExisteAutorizado := lExisteCancelado := false
    local upload := {=>}
    local directory, filePDF, fileXML, cancelPDF, cancelXML
    local empresa, anoMes

    // As vars que começam com "app" são de nível global (Public) definidas no main.prg
    empresa := appEmpresas:getEmpresa(cte:emp_id)

    // "2019-08-24T14:15:22Z"
    anoMes := Left(getNumbers(cte:dhEmi), 6)
    directory := appData:dfePath + empresa:CNPJ + '\CTe\' + anoMes + '\'
    filePDF := cte:chCTe + '-cte.pdf'
    fileXML := cte:chCTe + '-cte.xml'
    cancelPDF := cte:chCTe + '-cteCancelado.pdf'
    cancelXML := cte:chCTe + '-cteCancelado.xml'

    if hb_DirExists(directory)
        if (cte:situacao == "CANCELADO")
            lExisteAutorizado := true
            lExisteCancelado := hb_FileExists(directory + cancelPDF) .and. hb_FileExists(directory + cancelXML)
            if lExisteCancelado
                upload["pdfCancel"] := directory + cancelPDF
                upload["xmlCancel"] := directory + cancelXML
            endif
        else
            lExisteAutorizado := hb_FileExists(directory + filePDF) .and. hb_FileExists(directory + fileXML)
            if lExisteAutorizado
                upload["pdf"] := directory + filePDF
                upload["xml"] := directory + fileXML
            endif
        endif
    else
        hb_DirBuild(directory)
    endif

    default apiCTe := TApiCTe():new(cte)

    if !lExisteAutorizado

        if apiCTe:BaixarPDFdoDACTE()
            if hb_MemoWrit(directory + filePDF, apiCTe:pdf_dacte)
                upload["pdf"] := directory + filePDF
                saveLog("Arquivo PDF do DACTE salvo com sucesso: " + directory + filePDF)
            else
                saveLog("Erro ao escrever pdf binary em arquivo " + filePDF + " na pasta " + directory)
                cte:setUpdateEventos("OBTER PDF", date_as_DateTime(date(), false, false), "BINARY PDF", "Erro ao escrever PDF em arquivo. Ver log servidor local")
            endif
        else
            saveLog("Arquivo PDF do DACTE não retornado; Chave CTe: " + apiCTe:chave)
            cte:setUpdateEventos("OBTER PDF", date_as_DateTime(date(), false, false), "BINARY PDF", "Arquivo PDF do DACTE não retornado. Ver log servidor local")
        endif

        if apiCTe:BaixarXMLdoCTe()
            if hb_MemoWrit(directory + fileXML, apiCTe:xml_cte)
                upload["xml"] := directory + fileXML
                saveLog("Arquivo XML do CTe salvo com sucesso: " + directory + fileXML)
            else
                cte:setUpdateEventos("OBTER XML", date_as_DateTime(date(), false, false), "BINARY XML", "Erro ao escrever XML em arquivo. Ver log servidor local")
                saveLog("Erro ao escrever xml binary em arquivo " + fileXML + " na pasta " + directory)
            endif
        else
            cte:setUpdateEventos("OBTER XML", date_as_DateTime(date(), false, false), "BINARY XML", "Arquivo XML do CTe não retornado. Ver log servidor local")
            saveLog("Arquivo XML do CTe não retornado; Chave CTe: " + apiCTe:chave)
        endif

    endif

    if (cte:situacao == "CANCELADO") .and. !lExisteCancelado

        if apiCTe:BaixarPDFdoCancelamento()
            if hb_MemoWrit(directory + cancelPDF, apiCTe:pdf_cancel)
                upload["pdfCancel"] := directory + cancelPDF
                saveLog("Arquivo PDF do CTE CANCELADO salvo com sucesso: " + directory + cancelPDF)
            else
                saveLog("Erro ao escrever pdf binary em arquivo " + cancelPDF + " na pasta " + directory)
                cte:setUpdateEventos("OBTER PDF", date_as_DateTime(date(), false, false), "BINARY PDF", "Erro ao escrever PDF do CTe CANCELADO em arquivo. Ver log servidor local")
            endif
        else
            saveLog("Arquivo PDF do CTE CANCELADO não retornado; Chave CTe: " + apiCTe:chave)
            cte:setUpdateEventos("OBTER PDF", date_as_DateTime(date(), false, false), "BINARY PDF", "Arquivo PDF do CTE CANCELADO não retornado. Ver log servidor local")
        endif

        if apiCTe:BaixarXMLdoCancelamento()
            if hb_MemoWrit(directory + cancelXML, apiCTe:xml_cancel)
                upload["xmlCancel"] := directory + cancelXML
                saveLog("Arquivo XML do CTE CANCELADO salvo com sucesso: " + directory + cancelXML)
            else
                cte:setUpdateEventos("OBTER XML", date_as_DateTime(date(), false, false), "BINARY XML", "Erro ao escrever XML do CTE CANCELADO em arquivo. Ver log servidor local")
                saveLog("Erro ao escrever xml binary em arquivo " + cancelXML + " na pasta " + directory)
            endif
        else
            cte:setUpdateEventos("OBTER XML", date_as_DateTime(date(), false, false), "BINARY XML", "Arquivo XML do CTE CANCELADO não retornado. Ver log servidor local")
            saveLog("Arquivo XML do CTE CANCELADO não retornado; Chave CTe: " + apiCTe:chave)
        endif

    endif

    if !Empty(upload)
        upload["cte"] := cte
        upload["empresa"] := empresa
        cteUploadFiles(upload)
    endif

return