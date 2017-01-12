;;Max mass
logMmax = 14.

;;z vector in Ilbert
z_ilbert = [0.35,0.65,0.95,1.30,1.75,2.25,2.75,3.50]
;;z_ilbert = [0.35,0.65,0.95,1.30,1.75,2.25,2.75,3.50]

;;knee of the mass function in Ilbert (Chabrier IMF)
logMknee = [10.60,10.62,10.80,10.67,10.66,10.73,10.90,10.74]+0.24
Phiknee1 = [1.16,.77,.50,.53,.75,.50,.15,0.02]*1.e-3
Phiknee2 = [1.08,0.84,0.48,0.87,0.39,0.15,0.11,0.10]*1.e-3
alpha1 = [0.17,0.03,-0.67,0.11,-0.08,-0.33,-0.62,1.31]
alpha2 = [-1.40,-1.43,-1.51,-1.37,-1.6,-1.6,-1.6,-1.6]

;; Vector containing the errors for Ilbert parameters Eq. 2
elogMknee = [0.13,0.13,0.12,0.10,0.07,0.08,0.21,0.25]
ePhiknee1 = [0.35,0.25,0.32,0.21,0.09,0.07,0.08,0.01]*1.e-3
ePhiknee2 = [0.30,0.31,0.41,0.35,0.07,0.05,0.07,0.06]*1.e-3
ealpha1 = [0.61,0.70,0.70,0.70,0.30,0.33,0.9,0.87]
ealpha2 = [0.04,0.08,0.5,0.11,0.,0.,0.,0.]

;;SFR Schreiber
m0 = 0.5
eM0 = 0.07
a0 = 1.5
ea0 = 0.15
a1 = 0.3
ea1 = 0.08
m1 = 0.36
em1 = 0.3
a2 = 2.5
ea2 = 0.6

sigma_MS = 0.31 ;;dex
esigma_MS = 0.02
sigma_SB = sigma_MS
fSB = 0.033
efSB = 0.015
B_SB = 5.3
eB_SB = 0.4
x0 = 0.87
ex0 = 0.04

;; Kennicutt
Kuv = 1.65*1.7e-10     
;;1.70*1d-10 
Kir = 1.65*1.09e-10     
;;1.09*1d-10

;; Heinis2013
alpha_H13 = 0.72
ealpha_H13 = 0.08
IRX0 = 1.32
eIRX0 = 0.04

;;Pannella2015
alpha_P15 = 1.6
Auv0_P15 = -13.5
scat_P15 = 0.5

;;acc rate param (bimode)
;; restore, '../MC_fit/Chain/Samp_m8p0_z2p75_WeightPois_bimod_manu_results.save'
;; logA_sf = res_fit[0]+0.1
;; elogA_sf = error[0]
;; logA_qui = res_fit[1]+0.1
;; elogA_qui = error[1]
;; loglambda_break_sf = res_fit[2]
;; eloglambda_break_sf = error[2]
;; loglambda_break_qui = res_fit[3]
;; eloglambda_break_qui = error[3]
;; gamma_sf = [res_fit[4],res_fit[5]]
;; egamma_sf = [error[4],error[5]]
;; gamma_qui = [res_fit[6],res_fit[7]]
;; egamma_qui = [error[6],error[7]]

; logA_sf = -4.1
; logA_qui = -4.6
; gamma_sf = [-0.2,4.3]
; gamma_qui = [-0.2,3.2]
; loglambda_break_sf = 0.1
; loglambda_break_qui = -0.87

;;print, logA_sf, logA_qui, loglambda_break_sf, loglambda_break_qui, gamma_sf, gamma_qui
