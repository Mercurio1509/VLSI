

## Parte 1. Determinación de las resistencias de canal de transistores mínimos NMOS y PMOS para el proceso XH018. Módulo LPMOS: ne, pe (1,8V).

## Parte 2. Diseño de un inversor mínimo de tamaño óptimo
### B)
Para esta sección se monta el siguiente deck para simularse en Hspice, el cual se puede ubicar en los codigos fuente como "inversor_b":

```
*----------------------------------------------------------------------
* Parameters and models
*----------------------------------------------------------------------
.param H=4
.param F=2
.lib '/mnt/vol_NFS_rh003/Est_VLSI_I_2024/Sulecio_Hidalgo_I_2024_vlsi/tarea1/Hspice/lp5mos/xt018.lib' tm
.lib '/mnt/vol_NFS_rh003/Est_VLSI_I_2024/Sulecio_Hidalgo_I_2024_vlsi/tarea1/Hspice/lp5mos/param.lib' 3s
.lib '/mnt/vol_NFS_rh003/Est_VLSI_I_2024/Sulecio_Hidalgo_I_2024_vlsi/tarea1/Hspice/lp5mos/config.lib' default
.global vdd gnd
.option post
*----------------------------------------------------------------------
* Subcircuits
*----------------------------------------------------------------------
.subckt inv a y WN=220n WP=F*220n
xm0 y a gnd gnd ne W='WN' L=180n
+ as=-1 ad=-1 ps=-1 + pd=-1 nrs=-1 nrd=-1 m='(1*1)' par1='(1*1)' xf_subext=0
xm1 y a vdd vdd pe W='WP' L=180n
+ as=-1 ad=-1 ps=-1 + pd=-1 nrs=-1 nrd=-1 m='(1*1)' par1='(1*1)' xf_subext=0
.ends
*----------------------------------------------------------------------
* Simulation netlist
*----------------------------------------------------------------------
Vdd vdd gnd dc=1.8 power=0
Vin a gnd dc=0 pulse ( 0 1.8 0 100p 100p 2n 4.2n )
X1 a b inv
X2 b c inv M='H'
X3 c d inv M='H**2'
X4 d e inv M='H**3'
X5 e f inv M='H**4'
*----------------------------------------------------------------------
* Stimulus
*----------------------------------------------------------------------
.tran 10p 10n start=0
.plot v(c) v(d)
.print P(vdd)
.measure pwr AVG P(vdd) FROM=0ns TO=10ns
.measure tpdr
+ TRIG v(c) VAL=0.9 FALL=1 
+ TARG v(d) VAL=0.9 RISE=1
.measure tpdf
+ TRIG v(c) VAL=0.9 RISE=1
+ TARG v(d) VAL=0.9 FALL=1
.end
```
Se establecio el parametro F, el cual multiplica el ancho del transistor PMOS para asi variar la relacion PMOS/NMOS. De esta manera se ejecutan multiples simulaciones con distintas variaciones y se miden los retardos tpdr, tpdf y tpd para cada una de estas. Con lo cual se obtienen los siguientes resultados:

![image](https://github.com/Mercurio1509/VLSI_Tarea_1/assets/71583915/dd9a3d1c-47f6-479b-9a33-10c623f2bf1f)


![image](https://github.com/Mercurio1509/VLSI_Tarea_1/assets/71583915/a37dae86-cc4e-45e4-af69-fce87e8d44ab)


Con lo cual se obtiene que la relacion con el menor tiempo de retardo y menor diferencia de tpdf y tpdr se obtiene cuando  la relacion PMOS/NMOS es de 2.4/1.

Despues de esto se realiza una optimizacion automatizada utilizando Hspice, para esto se utiliza el siguiente deck, el cual se encuentra como "inversor_b2":
```
*----------------------------------------------------------------------
* Parameters and models
*----------------------------------------------------------------------
.param H=4
.temp 25
.lib '/mnt/vol_NFS_rh003/Est_VLSI_I_2024/Sulecio_Hidalgo_I_2024_vlsi/tarea1/Hspice/lp5mos/xt018.lib' tm
.lib '/mnt/vol_NFS_rh003/Est_VLSI_I_2024/Sulecio_Hidalgo_I_2024_vlsi/tarea1/Hspice/lp5mos/param.lib' 3s
.lib '/mnt/vol_NFS_rh003/Est_VLSI_I_2024/Sulecio_Hidalgo_I_2024_vlsi/tarea1/Hspice/lp5mos/config.lib' default
.global vdd gnd
.option post
*----------------------------------------------------------------------
* Subcircuits
*----------------------------------------------------------------------
.subckt inv a y WN=220n WP=440n
xm0 y a gnd gnd ne W='WN' L=180n
+ as=-1 ad=-1 ps=-1 + pd=-1 nrs=-1 nrd=-1 m='(1*1)' par1='(1*1)' xf_subext=0
xm1 y a vdd vdd pe W='WP' L=180n
+ as=-1 ad=-1 ps=-1 + pd=-1 nrs=-1 nrd=-1 m='(1*1)' par1='(1*1)' xf_subext=0
.ends
*----------------------------------------------------------------------
* Simulation netlist
*----------------------------------------------------------------------
Vdd vdd gnd dc=1.8 power=0
Vin a gnd dc=0 pulse ( 0 1.8 0 100p 100p 2n 4.2n )
X1 a b inv
X2 b c inv WP='P1' M='H'
X3 c d inv WP='P1' M='H**2'
X4 d e inv WP='P1' M='H**3'
X5 e f inv WP='P1' M='H**4'
*----------------------------------------------------------------------
* Optimization setup
*----------------------------------------------------------------------
.param P1=optrange(440n	,220n,880n) * search from 4 to 16, guess 8
.model optmod opt itropt=30 * maximum of 30 iterations
.measure bestratio param='P1/220n' * compute best P/N ratio
*----------------------------------------------------------------------
* Stimulus
*----------------------------------------------------------------------
.tran 10p 10n SWEEP OPTIMIZE=optrange RESULTS=diff MODEL=optmod
.plot v(c) v(d)
.print P(vdd)
.measure pwr AVG P(vdd) FROM=0ns TO=10ns
.measure tpdr
+ TRIG v(c) VAL=0.9 FALL=1 
+ TARG v(d) VAL=0.9 RISE=1
.measure tpdf
+ TRIG v(c) VAL=0.9 RISE=1
+ TARG v(d) VAL=0.9 FALL=1
.measure tpd param='(tpdr+tpdf)/2' goal=0
.measure diff param='tpdr-tpdf' goal = 0
.end
```

