#include "hmg.ch"
#include <fileio.ch>

procedure saveLog(text, lEncrypt)
   local path := Memvar->appData:systemPath + 'log\'
   local dateFormat := Set(_SET_DATEFORMAT, "yyyy.mm.dd")
   local logFile := 'dfe_log' + hb_ULeft(DToS(Date()),6) + '.txt'
   local h
   local t, msg := "", processos := ''

   DEFAULT lEncrypt := false

   if hb_FileExists(path + logFile)
      h := FOpen(path + logFile, FO_WRITE)
      FSeek(h, 0, FS_END)
   else
      h := hb_FCreate(path + logFile, FC_NORMAL)
      FWrite(h, 'Log de Sistema ' + Memvar->appData:displayName + hb_eol())
   endif
   if ValType(text) == 'A'
      for each t in text
         if !(ValType(t) == 'C')
            if (ValType(t) == 'N')
               t := hb_ntos(t)
            elseif (ValType(t) == 'D')
               t := hb_DToC(t)
            elseif (ValType(t) == 'L')
               t := iif(t, 'True', 'False')
            endif
         endif
         msg += t
      next
   else
      msg := text
   endif
   if !Empty(ProcName(3))
      processos := ProcName(3) + '(' + hb_ntos(ProcLine(3)) + ')->'
   endif
   if !Empty(ProcName(2))
      processos += ProcName(2) + '(' + hb_ntos(ProcLine(2)) + ')->'
   endif

   processos += ProcName(1) + '(' + hb_ntos(ProcLine(1)) + ')'

   if lEncrypt
      msg := "[ENCRYPT START =>]" + hb_eol() + auxEncrypt(msg) + hb_eol() + [<= ENCRYPT END]
   endif

   msg := hb_eol() + DtoC(Date()) + ' ' + Time() + ' [' + processos + '] ' + msg

   SET(_SET_DATEFORMAT, dateFormat)

   FWrite(h, msg)
   FClose(h)

return

function auxEncrypt(string)
    local char, encrypted := ''
    string := desacentuar(string)
    for each char in string
        encrypted += hb_ntos(asc(char)) + '#|@'
    next
    encrypted := hb_ULeft(encrypted, hmg_len(encrypted)-3)
return encrypted
