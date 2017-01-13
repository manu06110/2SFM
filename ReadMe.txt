Overview:

The code 2SFM is a semi-empirical model that generates catalogues of mock galaxies with stellar masses, redshifts, SFRs, UV luminosities (i.e. un-attenuated), and IR luminosities (i.e. dust attenuated). It was originally designed to reinforce the results derived from real datasets and to generate un-biased comparison samples to test observational selection effects. We present the 2SFM basic model in Bernhard et al. 2014 (Bernhard et al. 2015 and Bernhard et al. in prep for small updates), where we also show that it reproduces with a very good agreement the UV and the IR luminosity functions at least up to z~6. The code is written in IDL, very easy to use, and almost requires no interactions from the user. The associated paper can be found at http://adsabs.harvard.edu/abs/2014MNRAS.442..509B.

Model description:

This model is based on observed relationships. It generates mock galaxies in a fixed volume (i.e. up to a certain redshift) that is defined by the user. The total number of galaxies in the volume is given by the stellar mass functions of Ilbert et al. (2013) at various redshifts. We consider both populations explored in Ilbert et al. (2013), the quiescent and the star-forming galaxies. We define a redshift grid in which we interpolate (z<4) or extrapolate (z>4) the mass functions of Ilbert et al. (2013). We show in Bernhard et al. (2014) that the model works fine up to z~6. Once the redshifts and the stellar masses are defined, we allocate a SFR. For star forming galaxies, we first allocate SFRs that follow the main sequence (MS) of Schreiber et al. (2015; constitute an update of Bernhard et al. 2014) and then randomly scatter the MS SFRs following the SFR distribution of Sargent et al. (2012), and accounting for the Starburst population. For the quiescent population, since Ilbert et al. (2013) selection implies a cut in specific SFR (i.e. log(SFR/M/yr)<-11), we arbitrary allocate SFR within a Gaussian with -13<log(SFR/M/yr)<-11. Once SFRs are derived, and for star-forming galaxies only, we derive the attenuated (i.e. IR) and un-attenuated (i.e. UV) SFR components. To do so, we use the empirical relationship between stellar masses and attenuation (or IRX defined as log(Lir/Luv); Pannella et al. 2015). We then use Kennicutt et al. (1998), adapted for a Salpeter initial mass function (IMF), to derive the UV and IR luminosities of each mock star-forming galaxies.

Files description:

	The main folder contains the simcat directory and the catalogues directory. In the simcat directory, you can find all the IDL procedures that generate catalogues that will be saved in the catalogues directory. Within the simcat directory, you have:

	gen_cat.pro:
		It is the main procedure that runs the 2SFM. Open IDL and run "IDL> gen_cat". Otherwise, one can open gen_cat.pro and change the name of the catalogue (default: My_First_Catalogue), the field size (default: 1") and the low mass cut of the mass functions (default: 8). gen_cat.pro will run the different procedures, and ask if you want to save the catalogue containing the galaxy properties in the folder catalogues. In the catalogues directory, you can also find a txt file associated to the catalogue name. It contains the main parameters used to run the 2SFM.

	gen_mass.pro:
		It generates the stellar masses FOR STAR-FORMING GALAXIES ONLY following Ilbert et al. (2013). It also randomly allocate redshifts within the redshift grid.

	gen_passive.pro
		It generates the stellar masses for passive galaxies following Ilbert et al. (2013).

	gen_sfr.pro
		It allocates SFRs FOR STAR-FORMING GALAXIES ONLY following the MS of Schreiber et al. (2015) and randomly distribute them following the SFR distribution of Sargent et al. (2012).

	gen_att_lum.pro
		It considers, FOR STAR-FORMING GALAXIES ONLY, the empirical relationship between the stellar masses and the Attenuation of Pannella et al. (2015) to split the SFR into a UV and a IR components. It then uses Kennicutt et al. (1998) for a Sapeter IMF to work out UV and IR luminosities.

	gen_sfr_pass.pro
		It generates the SFR for quiescent galaxies.

	common_array_size, common_param, common_cosmo, and compute_dvdz:
		They are necessary background procedures.
		/!\ At the moment, if the redshift needs to be changed, it is by opening the file common_array_size and changing the parameter Nlog1plusz to a higher or a lower value /!\ It defines the number of element in the redshift grids and therefore the maximum redshift.

How to:

	Simplest way:
		>cd simcat
		>IDL
		>IDL> gen cat

	To change the parameters:
		To change the name of the catalogue, open gen_cat.pro and change the variable name. To change the size of the field, run ">IDL>gen_cat, field_size = YourValue" (needs to be done every run). To change the low mass cut, run ">IDL>gen_cat, logMcut = YourValue" (needs to be done every run).

	A certain number of basic functions needs to be added to the IDL library. Most common that are not in the IDL starting package:
		- Coyote libraries (https://www.idlcoyote.com).
		- SetDefaultValue (https://www.idlcoyote.com/programs/setdefaultvalue.pro).
		- push (https://hesperia.gsfc.nasa.gov/ssw/packages/s3drs/idl/util/push.pro).

Very important informations:
	- This written for a SALPETER initial mass function (logMsal = 0.24 + logMchab).

Future Work
	I am actually implementing AGNs at the moment (Part of my PhD work). It is almost there and it will be updated soon.
	I will carry on updating this version too, there are plenty of things to improve.
	Updating the mass functions to the last up-to-date of Davidzon et al. (2017).

Acknowledgement
	I gratefully acknowledge Matthieu Bethermin for the primary idea of this model. I also would like to thank Mark Sargent, Corentin Schreiber and James Mullaney for their deep implication in the project.

	When using 2SFM, please cite Bernhard et al. 2014 and references therein.

Contact
	If things comes to worst, please feel free to contact me: ebernhard1@sheffield.ac.uk










