PRO gen_cat, ID ,$    ; Identification           
             zgal ,$  ; Redshift
             Mstar,$  ; Stellar Mass         
             type,$   ; Flag: starburst (1) or MS (0)
             SFR,$    ; Star formation rate
             logSFRms,$ ;log of the MS star formation rate at the stellar mass and redshift
             sfrir,$  ; Attenuated SFR        
             sfruv,$  ; Un-attenuated SFR
             Lir,$    ; IR luminosity
             Luv, $   ; UV luminosity
             loglambda, $ ; log of the Eddington ratio
             sfactive, $ ; Flag: star-forming (1) or quiescent (2)
             field_size=field_size,$  ; Size of the field (in arc secondes)
             logMcut=logMcut,$ ; Low mass 
             mc=mc

  IF keyword_set(mc) EQ 0 THEN $
     disp_prog = 1
  
  ;; Give a name to the files
  ;;name = 'cat_m8_z2.0_bimod_StanBin'
  name = 'cat_m8_mass'

  IF keyword_set(mc) EQ 0 THEN BEGIN
     openw,lun, '../catalogues/'+name+'.txt', /get_lun
     printf,lun, '------------------------------------------------------------'
  ENDIF
  
  ;; Make IDL quiet
  !QUIET = 1
  
  ;;Define params
  stop
  field_size = 10
  logMcut = 8.

  ;;Call of the function that generate the mock catalogue
  gen_mass, field_size,$
            logMcut,$ 
            Mstar,$     
            zgal,$      
            ID, $
            lun, $
            dsche = dsche,$ 
            mc = mc,$        
            mark_evol=mark_evol, $
            disp_prog = disp_prog

  IF keyword_set(mc) EQ 0 THEN BEGIN
     printf,lun, '------------------------------------------------------------'
     printf,lun, '------------------------------------------------------------'
  ENDIF

  gen_passive, field_size, $
               logMcut, $
               Mstar_pass, $
               zgal_pass, $
               ID_pass, $
               lun, $
               mc = mc, $
               disp_prog = disp_prog

  IF keyword_set(mc) EQ 0 THEN BEGIN
     printf,lun, '------------------------------------------------------------'
     printf,lun, '------------------------------------------------------------'
  ENDIF

  gen_sfr,ID, $
          Mstar,$         
          zgal,$          
          type,$          
          SFR,$           
          logSFRms,$      
          logsSFRexcess,$
          lun, $
          mc = mc, $
          disp_prog = disp_prog

  IF keyword_set(mc) EQ 0 THEN BEGIN
     printf,lun, '------------------------------------------------------------'
     printf,lun, '------------------------------------------------------------'
  ENDIF

  gen_att_lum,Mstar,$
              zgal,$
              type,$
              SFR,$
              logSFRms, $
              logsSFRexcess, $
              SFRir,$
              SFRuv,$
              Lir,$
              Luv, $
              lun, $
              mc = mc, $
              disp_prog = disp_prog

  IF keyword_set(mc) EQ 0 THEN BEGIN
     printf,lun, '------------------------------------------------------------'
     printf,lun, '------------------------------------------------------------'
  ENDIF
  
  ;;We combine passive and active
  sfactive = [Mstar*0.+1.,Mstar_pass*0.]
  Mstar = [Mstar,Mstar_pass]
  SFR = [SFR,Mstar_pass*0]
  zgal = [zgal,zgal_pass]
  ID = [ID,max(ID)+ID_pass]

  IF keyword_set(mc) EQ 0 THEN BEGIN
     printf,lun, '****************************************'
     printf,lun, '        FULL MOCK SF CATALOGUE'
     printf,lun, 'FIELD SIZE: '+strtrim(field_size,1)+' square degrees'
     printf,lun, 'REDSHIFT RANGE: '+strtrim(min(zgal),1)+ $
            ' - '+strtrim(max(zgal),1)
     printf,lun, 'NUMBER OF GALAXIES: '+strtrim(n_elements(Mstar),1)
     o = where(sfactive EQ 1.,n_o)
     frac = double(n_o)/double(n_elements(Mstar))*100
     printf,lun, 'FRACTION OF SF GALAXIES: '+strtrim(frac,1)+' %'
     printf,lun, '****************************************'
     
     printf,lun, '------------------------------------------------------------'
     printf,lun, '------------------------------------------------------------'
  ENDIF
  
  gen_sfr_pass, Mstar,$
                zgal,$
                SFR,$
                logSFRms, $
                sfactive, $
                mc = mc
  
  gen_bhar_mass,field_size, $
                Mstar,$
                zgal,$
                type,$
                SFR,$
                logSFRms, $
                logsSFRexcess, $
                SFRir,$
                SFRuv,$
                Lir,$
                Luv, $
                loglambda, $
                sfactive, $
                lun, $
                mc = mc, $
                disp_prog = disp_prog

  ; gen_bhar_one_comp, field_size, $
  ;                  Mstar,$
  ;                  zgal,$
  ;                  type,$
  ;                  SFR,$
  ;                  logSFRms, $
  ;                  logsSFRexcess, $
  ;                  SFRir,$
  ;                  SFRuv,$
  ;                  Lir,$
  ;                  Luv, $
  ;                  loglambda, $
  ;                  sfactive, $
  ;                  AGNflag, $
  ;                  lun, $
  ;                  mc = mc, $
  ;                  disp_prog = disp_prog

  IF keyword_set(mc) EQ 0 THEN BEGIN
     printf,lun, '------------------------------------------------------------'
     printf,lun, '------------------------------------------------------------'
     free_lun, lun
  ENDIF

  logfile = 'no'
  IF keyword_set(mc) EQ 0 THEN $
     READ, logfile, PROMPT='Do you want to open the log file? (no)'
  
  IF logfile EQ 'yes' THEN $
     SPAWN, 'open ../catalogues/'+name+'.txt &'
  
  saving = 'no'
  IF keyword_set(mc) EQ 0 THEN $
     READ, saving, PROMPT='Do you want to save it? (no)'
  
  IF saving EQ 'yes' THEN BEGIN
     
     o = where(loglambda GT -1.3)
     loglambda = loglambda[o]
     SFR = SFR[o]
     zgal = zgal[o]
     Mstar = Mstar[o]
     sfactive = sfactive[o]

     stop

     save, filename = '../catalogues/'+name+'.save',$
           FIELD_SIZE, $
           ID ,$             ;; ID
           zgal ,$           ;; redshift
           Mstar,$           ;; Mass
           type,$            ;; Ignore
           SFR,$             ;; The star formation rate (SFR)
           logSFRms,$        ;; Ignore
           logsSFRexcess, $
           sfrir,$           ;; Ignore
           sfruv,$           ;; Ignore
           Lir,$             ;; The IR luminosity
           Luv, $            ;; The UV luminosity
           loglambda, $
           sfactive

     print, 'Finished without errors and saved the mock catalogue'

  ENDIF ELSE BEGIN
     IF keyword_set(mc) EQ 0 THEN $
        print, 'Finished without errors but DID NOT saved the mock catalogue'
  ENDELSE 
  
END
