#define true .T.
#define false .F.

procedure startTimer()
    SetProperty("main", "Timer_DFE", "Enabled", true)
return

procedure stopTimer()
    SetProperty("main", "Timer_DFE", "Enabled", false)
return
