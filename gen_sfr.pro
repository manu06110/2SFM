;; Function gen_sfr
PRO gen_sfr, ID, $
             Mstar,$           
             zgal,$            
             type,$            
             SFR,$             
             logSFRms,$ 
             lun, $
             mc = mc, $
             disp_prog = disp_prog
  
  
@common_array_size
@common_cosmo
@common_param

  ;; Open the progress bar (if specified)
  IF keyword_set(disp_prog) THEN BEGIN
     cgProgressBar = Obj_New("CGPROGRESSBAR", title='Generate SFRs')
     cgProgressBar -> Start
  END
  
  ;;----------------------------------------------
  ;; Generate the total SFR for MS and SB galaxies (Schreiber+2015 (MS) and Sargent+2012 (distribution))
  ;;----------------------------------------------

  IF keyword_set(mc) THEN BEGIN
     m0 = m0+em0*randomn(seed)
     m1 = m1+em1*randomn(seed)
     a0 = a0+ea0*randomn(seed)
     a1 = a1+ea1*randomn(seed)
     a2 = a2+ea2*randomn(seed)
     fsb = fsb+efsb*randomn(seed)
     IF fsb LT 0 THEN fsb = 0.01
     x0 = x0+ex0*randomn(seed)
     sigma_MS = sigma_MS+esigma_MS*randomn(seed)
     B_SB = B_SB+eB_SB*randomn(seed)
  ENDIF

  IF keyword_set(disp_prog) THEN $
     cgProgressBar -> Update, 10
  
  Ngal = n_elements(Mstar)
  
  m = alog10(Mstar/1d9)
  r = alog10(1.+zgal)
  
  r2 = m-m1-a2*r
  o = where(r2 LT 0,n_o)
  IF n_o GT 0 THEN $
     r2[o] = 0.

  ;; SFR on the MS (Schreiber+2015)
  logSFRms = m-m0+a0*r-a1*r2*r2

  IF keyword_set(disp_prog) THEN $
     cgProgressBar -> Update, 16
  
  ;; Define 2% of the galaxies as SB
  type = Mstar*0.
  SB = randomu(seed,Ngal*fsb)*Ngal
  type(SB) = 1.

  IF keyword_set(disp_prog) THEN $
     cgProgressBar -> Update, 32
  
  ;; Distribute the SFR following the SFR distribution of Sargent+2012
  logSFR = logSFRms+alog10(x0)+sigma_MS*randomn(seed, Ngal)

  IF keyword_set(disp_prog) THEN $
     cgProgressBar -> Update, 48
  
  logSFR[SB] = logSFR[SB]+alog10(B_SB)-alog10(x0)

  IF keyword_set(disp_prog) THEN $
     cgProgressBar -> Update, 63
  
  SFR = 10.^logSFR
  SFRms = 10.^logSFRms

  IF keyword_set(disp_prog) THEN $
     cgProgressBar -> Update, 89
  
  logsSFRexcess = alog10(SFR)-alog10(SFRms)

  IF keyword_set(disp_prog) THEN $
     cgProgressBar -> Update, 100


  IF keyword_set(mc) EQ 0 THEN BEGIN
     printf,lun, 'SFR distribution parameters'
     printf,lun,'m0,a0,a1,a2,sigma_MS,sigma_SB,fSB,B_SB,x0'
     printf,lun,strtrim(m0,1)+' ', $
            strtrim(a0,1)+' ', $
            strtrim(a1,1)+' ', $
            strtrim(a2,1)+' ', $
            strtrim(sigma_MS,1)+' ', $
            strtrim(sigma_SB,1)+' ', $
            strtrim(fSB,1)+' ', $
            strtrim(B_SB,1)+' ', $
            strtrim(x0,1)
     
     printf,lun, '****************************************'
     printf,lun, '    SFR DISTRIBUTION (Schreiber+2015)'
     printf,lun, 'FRACTION OF SB GALAXIES: '+strtrim(fsb*100,1)+' PERCENT'
     printf,lun, 'MIN SFR: '+strtrim(min(10.^logSFR),1)+' Msun/yr'
     printf,lun, 'MAX SFR: '+strtrim(max(10.^logSFR),1)+' Msun/yr'
     printf,lun, '****************************************'
  ENDIF
  
END
