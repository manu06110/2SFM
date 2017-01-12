PRO gen_sfr_pass, Mstar,$
                  zgal,$
                  SFR,$
                  logSFRms, $
                  sfactive, $
                  mc = mc

@common_array_size
@common_cosmo
@common_param
  
  pass = where(sfactive EQ 0,n_pass)
  logsSFR_min = -13. ; Correspond to a sSFR for a galaxy with Lir=10^9 Lsun and M=10^12 Msun
  logsSFR_max = -11. ; Ilbert 2013
  logsSFR = -12 + randomn(seed,n_pass)
  logSFR = logsSFR + alog10(Mstar[pass])
  SFR[pass] = 10.^logSFR
  
END
