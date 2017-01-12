PRO compute_dVdz, Dl, z, dVdz

@common_cosmo
@common_array_size

;dV en Mpc/sr (c'est du comobile)
;from Hogg 1999 (astroph)

E = sqrt(Omega_m*(1.+z)^3+Omega_lambda)
DH = 3000./(H0/100.)
Da = dl/(1.+z)^2
dVdz = DH*(1.+z)^2*Da^2/E

END
