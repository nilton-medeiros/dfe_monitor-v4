#include "hmg.ch"
#include <fileio.ch>

procedure consoleLog(text)
   local path := appData:systemPath + 'log\'
   local dateFormat := Set(_SET_DATEFORMAT, "yyyy.mm.dd")
   local logFile := 'console.log'
   local h, n := 0
   local t, msg := "", processos := ''

   if hb_FileExists(path + logFile)
      h := FOpen(path + logFile, FO_WRITE)
      FSeek(h, 0, FS_END)
   else
      h := hb_FCreate(path + logFile, FC_NORMAL)
      FWrite(h, 'Console Log de Sistema ' + appData:displayName + hb_eol() + hb_eol())
   endif
   if ValType(text) == 'A'
      for each t in text
         if !(ValType(t) == 'C')
            if (ValType(t) == 'N')
               t := hb_ntos(t)
            elseif (ValType(t) == 'D')
               t := hb_DToC(t)
            elseif (ValType(t) == 'L')
               t := iif(t, 'true', 'false')
            else
               t := "Parametro inválido: ValType(t): " + ValType(t) + " | Posição: " + hb_ntos(n)
            endif
         endif
         n++
         msg += t
      next
   else
      msg := text
   endif
   if !Empty(ProcName(2))
      processos := ProcName(2) + '(' + hb_ntos(ProcLine(2)) + ')->'
   endif

   processos += ProcName(1) + '(' + hb_ntos(ProcLine(1)) + ')'

   msg := DtoC(Date()) + ' ' + Time() + ' [' + processos + ']' + hb_eol() + "    " + msg + hb_eol() + hb_eol()

   SET(_SET_DATEFORMAT, dateFormat)

   FWrite(h, msg)
   FClose(h)

return
