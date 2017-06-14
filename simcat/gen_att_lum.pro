PRO gen_att_lum, Mstar,$
                 zgal,$
                 type,$
                 SFR,$
                 logSFRms, $
                 SFRir,$
                 SFRuv,$
                 Lir,$
                 Luv, $
                 lun, $
                 mc = mc, $
                 disp_prog = disp_prog
  
@common_array_size
@common_cosmo
@common_param

  ;; Open the progress bar (if specified)
  IF keyword_set(disp_prog) THEN BEGIN
     cgProgressBar = Obj_New("CGPROGRESSBAR", title='Generate Luminosities')
     cgProgressBar -> Start
  ENDIF
  
  ;;------------------------------------------------------------------------------
  ;; Generate the UV and IR luminosities for star-forming galaxies (Pannella+2015)
  ;;------------------------------------------------------------------------------
  logMstar = alog10(Mstar)
  
  Auv = alpha_P15*logMstar + Auv0_P15 + $
        scat_P15*randomn(seed,n_elements(logMstar))

  o = where(Auv LT 0.,n_o)
  IF n_o GT 0 THEN $
     Auv[o] = 0.
  
  IF keyword_set(disp_prog) THEN $
     cgProgressBar -> Update, 70

  ;;From Heinis+2014
  IRX = alog10(10.^(Auv*0.4) * 1.68 -1.)

  R1500 = 2.5*IRX+2.5*alog10(Kir/Kuv)
  
  Lir = 10.^(0.4*R1500)*SFR/Kir/(1+10.^(0.4*R1500)) ;;[Lsun]
  SFRir = Kir*Lir
  SFRuv = SFR-SFRir
  Luv = 1./Kuv*SFRuv            ;;[Lsun]

  IF keyword_set(disp_prog) THEN $
     cgProgressBar -> Update, 100

  
  IF keyword_set(mc) EQ 0 THEN BEGIN
     printf,lun, 'Attenuation relation parameters'
     printf,lun,'slope, constant, scatter, Kir, Kuv '
     printf,lun,strtrim(alpha_P15,1)+' ', $
            strtrim(Auv0_P15,1)+' ', $
            strtrim(scat_P15,1)+' ', $
            strtrim(Kir,1)+' ', $
            strtrim(Kuv,1)
     
     printf,lun, '****************************************'
     printf,lun, '  ATTENUATION RELATION (PANNELLA+2015)'
     printf,lun, 'RANGE LIR: '+strtrim(min(Lir),1)+' - '+ $
            strtrim(max(Lir),1)+' Lsun'
     printf,lun, 'RANGE LUV: '+strtrim(min(Luv),1)+' - '+ $
            strtrim(max(Luv),1)+' Lsun'
     printf,lun, '****************************************'
  ENDIF
  
END


