

## Parte 1. Determinación de las resistencias de canal de transistores mínimos NMOS y PMOS para el proceso XH018. Módulo LPMOS: ne, pe (1,8V).

## Parte 2. Diseño de un inversor mínimo de tamaño óptimo
### Parte 2.B

#### Optimizacion manual
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

![image](https://github.com/Mercurio1509/VLSI_Tarea_1/assets/71583915/0c675cb3-c537-4926-a56e-da6aca490c88)



![image](https://github.com/Mercurio1509/VLSI_Tarea_1/assets/71583915/ee100e6a-5a06-4931-8936-dd97a02590ec)




Con lo cual se obtiene que la relacion con el menor tiempo de retardo y menor diferencia de tpdf y tpdr se obtiene cuando  la relacion PMOS/NMOS es de 2.4/1.

#### Optimizacion automatica
Despues, se realiza una optimizacion automatizada utilizando Hspice, para esto se utiliza el siguiente deck, el cual se encuentra como "inversor_b2":
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
Se ejecuta la simulacion y se obtiene que la mejor relacion PMOS/NMOS es de 4, junto a la siguiente informacion:

![image](https://github.com/Mercurio1509/VLSI_Tarea_1/assets/71583915/0cd9cfc7-546a-4c2e-90a0-3bb3b5c006f4)



#### Potencia
 Se mide la potencia para las relaciones PMOS/NMOS obtenidas con ambas optimizaciones:
 
 ![image](https://github.com/Mercurio1509/VLSI_Tarea_1/assets/71583915/aaf328f9-1c03-4f3e-a8fa-eadab5952bf8)


#### Comparación de resultados
Para escoger cual de las 2 soluciones es mas deseable es necesario tener muy en cuenta cuales son los requisitos de diseño. La optimizacion a mano tiene un area menor debido en comparacion a la optimizacion automatica, esto debido a que el ancho del PMOS es 2.4 veces mas grande que el NMOS, a diferencia del otro caso donde es 4 veces mas ancho que el NMOS. Esta optimizacion tambien tiene un menor retardo tpd, por lo cual en promedio el retardo de proparacion es menor para esta optimizacion. 

La relacion obtenida de manera automatica tiene una menor diferencia entre el tpdr y tpdf, por lo cual el retardo de cuando la compuerta conmuta de 0 a 1 es casi igual que cuando esta conmuta de 1 a 0, ademas tambien posee la ventaja de presentar un menor consumo de potencia en comparacion a la solucion obtenida de manera manual.

En conclusion, para escoger una solucion se debe decidir que es preferible, si se necesita la compuerta de menor area y menor retardo de propagacion, la relacion 2.4/1 obtenida a mano es mejor. Mientras que si desean tpdf y tpdr lo mas iguales posibles y un menor consumo de potencia, es mejor la relacion 4/1 obtenida de manera automatica con Hspice.


