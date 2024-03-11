* mosiv.sp
*----------------------------------------------------------------------
* Parameters and models
*----------------------------------------------------------------------
.lib '/mnt/vol_NFS_rh003/Est_VLSI_I_2024/Leiva_Solano_I_2024_vlsi/tutorial//Hspice/lp5mos/xt018.lib' tm
.lib '/mnt/vol_NFS_rh003/Est_VLSI_I_2024/Leiva_Solano_I_2024_vlsi/tutorial/Hspice/lp5mos/param.lib' 3s
.lib '/mnt/vol_NFS_rh003/Est_VLSI_I_2024/Leiva_Solano_I_2024_vlsi/tutorial/Hspice/lp5mos/config.lib' default
*.include '../models/ibm065/models.sp'
.temp 25
.option post

.option post accurate nomod brief
.option post_version=9007
.option runlvl = 5
.op
*----------------------------------------------------------------------
* Simulation netlist
*----------------------------------------------------------------------
*nmos
Vgs g gnd 0
Vds d gnd 0
xm0 d g gnd gnd ne W=220n L=180n
*----------------------------------------------------------------------
* Stimulus
*----------------------------------------------------------------------
.dc Vds 0 1.0 0.05 SWEEP Vgs 0 1.0 0.2
.end
