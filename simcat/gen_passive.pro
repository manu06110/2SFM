PRO gen_passive, field_size, $
                 logMcut, $
                 Mstar, $
                 zgal, $
                 ID, $
                 lun, $
                 mc = mc, $
                 disp_prog = disp_prog

  
@common_array_size
@common_cosmo
@common_param

  ;; Open the progress bar (if specified)
  IF keyword_set(disp_prog) THEN BEGIN 
     cgProgressBar = Obj_New("CGPROGRESSBAR", title='Generate Passives')
     cgProgressBar -> Start
  ENDIF
  
  ;; adapt the grid in redshift  
  if field_size gt 10. then begin
     zgridfactor = sqrt(field_size/10.)
     Nlog1plusz = Nlog1plusz*zgridfactor
     dlog1plusz = dlog1plusz*1./zgridfactor
  endif  

  omega = (2.*!PI/360.)^2*field_size ;omega converti en steradian

  ;; Define the redshift grid
  log1plusz = dlog1plusz*(findgen(Nlog1plusz)+1.)
  log1pluszgrid = dlog1plusz*(findgen(Nlog1plusz+1)+0.5)
  z = 10.^log1plusz-1.
  zgrid = 10.^log1pluszgrid-1.
  dz = deriv(z)
  Nz = n_elements(z)

  ;; For each redshift boundary, we compute the luminosity distance (DL)                            
  DL = lumdist(z, H0 = H0 , Omega_M = Omega_m, Lambda0 = Omega_lambda,/SILENT)

  ;; For each redshift bin, we compute the ratio between the element
  ;; of volume and the element of redshift (i.e. dV/dz)                        
  compute_dVdz, Dl, z, dVdz

  ;;----------------------------
  ;; Generate the stellar masses (Davidzon+2017)
  ;;----------------------------

  logMmax = 15.
  
  nbr_points_dex=50
  Nm=(logMmax-logMcut)*nbr_points_dex
  M = 10.^(logMcut+(logMmax-logMcut)/Nm*(findgen(Nm)+1))
  dlogm=deriv(alog10(M))

  Mstar = -1.                   
  zgal = -1.
  
  ;; Ilbert+2013 parameters for the passive galaxies
  zvec = [0.35,0.65,0.95,1.3,1.75,2.25,2.75,3.25,4.]
  
  logMknee = [10.83,10.83,10.75,10.56,10.54,10.69,10.24,10.10,10.27]+0.24
  ;elogMknee = [0.08,0.04,0.03,0.03,0.04,0.06,0.09]
  Phiknee1 = [0.098,0.012,1.724,0.757,0.251,0.068,0.028,0.010,0.004]*1.e-3
  ;ePhiknee1 = [0.2,0.,0.,0.,0.,0.,0.]*1e-3
  Phiknee2 = [1.58,1.44,0.,0.,0.,0.,0.,0.,0.]*1.e-3
  ;ePhiknee2 = [0.07,0.1,0.09,0.03,0.01,0.01,0.004]*1d-3
  alpha1 = [-1.3,-1.46,-0.07,0.53,0.93,0.17,1.15,1.15,1.15]
  ;ealpha1 = [0.18,0.05,0.05,0.06,0.09,0.22,0.93]
  alpha2 = [-0.39,-0.21,0.,0.,0.,0.,0.,0.,0.]
  
  IF keyword_set(mc) THEN BEGIN
     logMknee = logMknee+elogMknee*randomn(seed)
     Phiknee1 = Phiknee1+ePhiknee1*randomn(seed)
     Phiknee2 = Phiknee2+ePhiknee2*randomn(seed)
     alpha1 = alpha1+ealpha1*randomn(seed)
     alpha2 = alpha2+ealpha2*randomn(seed)
  ENDIF
  
  FOR i = 0, Nz-1 DO BEGIN

     IF zgrid(i) LE .5 THEN BEGIN

        logMknee_z = logMknee[0] ; on a la valeur de logMknee en z grid (i)
        Mknee_z = 10^logMknee_z
        Phiknee1_z = Phiknee1[0]
        Phiknee2_z = Phiknee2[0]
        alpha1_z = alpha1[0]
        alpha2_z = alpha2[0]
        
        Phi=1d*exp(-M/Mknee_z)*(Phiknee1_z*(M/Mknee_z)^alpha1_z+$
                                Phiknee2_z*(M/Mknee_z)^alpha2_z)/Mknee_z*M*alog(10)
     ENDIF ELSE BEGIN

        logMknee_z = INTERPOL (logMknee,zvec,zgrid(i)) 
        Mknee_z = 10^logMknee_z
        logPhiknee_z = INTERPOL (alog10(Phiknee1),zvec,zgrid(i))
        Phiknee_z = 10^logPhiknee_z
        
        IF zgrid(i) LE 3. THEN $
           alpha_z = INTERPOL (alpha1,zvec,zgrid(i)) $
        ELSE $
           alpha_z = 3.26       

        Phi=1d*exp(-M/Mknee_z)*Phiknee_z*(M/Mknee_z)^alpha_z/Mknee_z*M*alog(10) 
     ENDELSE
     
     o = where(Phi LT 0., n_o)
     IF n_o GT 0 THEN $
        Phi[o] = 0
     
     NsupM = dblarr(Nm)
     NsupM(Nm-1) = dlogm(Nm-1)*phi(Nm-1)
     
     for j = 1, Nm-1 do begin
        NsupM(Nm-1-j) = NsupM(Nm-j)+phi(Nm-1-j)*dlogm(Nm-1-j)
     endfor
     
     if NsupM(0)*dvdz(i)*dz(i)*omega gt 0. then begin
        Ngal = randomu(seed,POISSON = NsupM(0)*dvdz(i)*dz(i)*omega, /double)
     endif else begin
        ngal=0.
     endelse
     NsupMrenorm=NsupM/NsupM(0)

     if ngal gt 0. then begin
        X = randomu(seed,ngal)           
        Mslice = interpol(M,NsupMrenorm,X)
        Mstar = [Mstar , Mslice] 
        
        ;; Randomly allocate a z within the slice
        zslice=zgrid(i)+(zgrid(i+1)-zgrid(i))*randomu(seed,ngal)
        zgal = [zgal, zslice] 
     endif

     IF keyword_set(disp_prog) THEN $
        cgProgressBar -> Update, double(i+1)/double(Nz)*100
  ENDFOR
  
  Mstar = Mstar[1:n_elements(Mstar)-1]
  zgal = zgal[1:n_elements(zgal)-1]

  ID = findgen(n_elements(zgal))

  ;; Print the log file
  IF keyword_set(mc) EQ 0 THEN BEGIN
     printf,lun, 'Quiescent Mass function parameters (bin in z, log(Mknee), Phi1, Phi2, alpha1, alpha2)'
     
     printf,lun,strtrim(z_david,1), $
            strtrim(logMknee,1), $
            strtrim(Phiknee1,1), $
            strtrim(Phiknee2,1), $
            strtrim(alpha1,1), $
            strtrim(alpha2,1)
     
     
     printf,lun, '****************************************'
     printf,lun, '     MASS FUNCTION QUIESCENT GALAXIES (Ilbert+2013)'
     printf,lun, 'NUMBER OF QUI GALAXIES GENERATED: '+strtrim(n_elements(zgal),1)
     printf,lun, 'LOW MASS CUT: '+strtrim(logMcut,1)+' solar masses'
     printf,lun, 'HIGH MASS CUT: '+strtrim(logMmax,1)+' solar masses'
     printf,lun, 'MAX REDSHIFT: '+strtrim(max(zgal),1)
     printf,lun, '****************************************'
  ENDIF
  
END
