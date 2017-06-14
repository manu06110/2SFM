PRO gen_mass, field_size,$
              logMcut,$ 
              Mstar,$     
              zgal,$      
              ID, $
              lun, $
              mc = mc,$        
              disp_prog = disp_prog
  
;; uploading some files
@common_array_size
@common_cosmo
@common_param

  ;; updating the log file 
  IF keyword_set(mc) EQ 0 THEN BEGIN
     printf,lun, 'SF Mass Function parameters (z, log(M_knee), Phi1, Phi2, apha1, alpha2)'
     printf,lun,strtrim(z_david,1), $
                strtrim(logMknee,1), $
                strtrim(Phiknee1,1), $
                strtrim(Phiknee2,1), $
                strtrim(alpha1,1), $
                strtrim(alpha2,1)
  ENDIF
  

  ;; Open the progress bar (if specified)
  IF keyword_set(disp_prog) THEN BEGIN
     cgProgressBar = Obj_New("CGPROGRESSBAR", title='Generate Masses')
     cgProgressBar -> Start
  ENDIF

  ;; adapt the grid in redshift  
  IF field_size GT 10. THEN BEGIN
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
  DL = lumdist(z, H0=H0 , Omega_M=Omega_m, Lambda0=Omega_lambda,/SILENT)

  ;; For each redshift bin, we compute the ratio between the element
  ;; of volume and the element of redshift (i.e. dV/dz)
  compute_dVdz, Dl, z, dVdz
  
  ;;----------------------------
  ;; Generate the stellar masses (Ilbert+2013)
  ;;----------------------------

  logM = logMcut
  increment = 1
  WHILE max(logM) LT logMmax DO BEGIN
     logM = [logM,logM[increment-1]+0.02]
     increment += 1
  ENDWHILE
  
  dlogm=deriv(logM)
  M = 10.^logM
  Nm = n_elements(logM)
 
  IF keyword_set(mc) THEN BEGIN
     logMknee = logMknee+elogMknee*randomn(seed)
     Phiknee1 = Phiknee1+ePhiknee1*randomn(seed)
     Phiknee2 = Phiknee2+ePhiknee2*randomn(seed)
     alpha1 = alpha1+ealpha1*randomn(seed)
     alpha2 = alpha2+ealpha2*randomn(seed)
  ENDIF
 
  ;;Loop on the redshift
  FOR i = 0, Nz-2 DO BEGIN
     ;; Using a double Schechter for z<4
     IF zgrid[i] LT 4. THEN BEGIN
        Mknee_z = INTERPOL(10.^logMknee,z_david,zgrid[i])
        Phiknee1_z = INTERPOL(Phiknee1,z_david,zgrid[i])
        Phiknee2_z = INTERPOL(Phiknee2,z_david,zgrid[i])
        alpha1_z = INTERPOL(alpha1,z_david,zgrid[i])
        alpha2_z = INTERPOL(alpha2,z_david,zgrid[i])
        
        Phi_z = 1d*exp(-M/Mknee_z)* $
                (Phiknee1_z*(M/Mknee_z)^alpha1_z+ $
                 Phiknee2_z*(M/Mknee_z)^alpha2_z)/Mknee_z*M*alog(10)
        
           
     ENDIF
     ;; For z>4, we use a different redshift evolution of the parameters as suggested in
     ;; Sargent+2012
     IF zgrid[i] GE 4. THEN BEGIN
        alpha = 1.3*(1+(zgrid[i]-2.))^0.19               
        Mknee = 10.^(alog10(10.^11.20)-0.3*(zgrid[i]-3.5))
        phi_knee = 0.00470*(1.+zgrid[i])^(-2.4)
        
        Phi_z = 1d*phi_knee*(M/Mknee)^(-alpha)*exp(-M/Mknee)*(M/Mknee)*alog(10)
     ENDIF
     
     NsupM = dblarr(Nm)  
     NsupM(Nm-1) = dlogm(Nm-1)*phi_z(Nm-1)
     
     FOR j = 1, Nm-1 DO BEGIN
        NsupM(Nm-1-j) = NsupM(Nm-j)+phi_z(Nm-1-j)*dlogm(Nm-1-j)
     ENDFOR

     IF NsupM[0]*dvdz[i]*dz[i]*omega GT 0 THEN $
        Ngal = randomu(seed,POISSON = NsupM[0]*dvdz[i]*dz[i]*omega, /double) $
     ELSE $
        Ngal = 0.
     
     NsupMrenorm=NsupM/NsupM(0)

     IF Ngal GT 0. THEN BEGIN
        X = randomu(seed,Ngal)
        Mslice = interpol(M,NsupMrenorm,X)

        push, Mstar, Mslice
  
        ;; Randomly distribute the galaxies within the z slice
        zslice=zgrid[i]+(zgrid[i+1]-zgrid[i])*randomu(seed,ngal)
   
        push, zgal, zslice       
     ENDIF

     IF keyword_set(disp_prog) THEN $
        cgProgressBar -> Update, double(i+1)/double(Nz)*100
     
  ENDFOR

  IF keyword_set(mc) EQ 0 THEN BEGIN
     printf,lun, '****************************************'
     printf,lun, '     MASS FUNCTION STAR-FORMING GALAXIES (Davodzon+2017)'
     printf,lun, 'NUMBER OF SF GALAXIES GENERATED: '+strtrim(n_elements(zgal),1)
     printf,lun, 'LOW MASS CUT: '+strtrim(logMcut,1)+' solar masses'
     printf,lun, 'HIGH MASS CUT: '+strtrim(logMmax,1)+' solar masses'
     printf,lun, 'MAX REDSHIFT: '+strtrim(max(zgal),1)
     printf,lun, '****************************************'
  ENDIF
  
  ID = findgen(n_elements(zgal))

END
