

## Parte 1. Determinación de las resistencias de canal de transistores mínimos NMOS y PMOS para el proceso XH018. Módulo LPMOS: ne, pe (1,8V).

En esta sección calcularemos el valor de la resistencia efectiva para los transistores NMOS y PMOS para el proceso XH018 con una tensión de alimentación de 1.8V. Para el calculo primero debemos localizar ciertos valores en la hoja de datos provista, estos valores son la corriente en high y en low. Comenzamos con el cálculo de la resistencia efectiva para el transistor NMOS que tiene unas corrientes de IH=475uA/um y IL=3pA/um, con estos valores calculamos la corriente efectiva Ieff=(IH+IL)/2 obteniendo un valor de Ieff=237,5uA/um, multiplicamos por el L del transistor que para este caso es de 180nm y obtenemos un nuevo valor de Ieff=42.74uA dejándolo solo en términos de la corriente. Con esto ya tenemos todo lo necesario para calcular la resistencia efectiva con la siguiente fórmula.

$$
R_{Neff}=\frac{V_{DD}}{2I_{eff}}
$$

Obtenemos para NMOS un valor de $R_{Neff}=21k \Omega$.

Para el caso del PMOS es seguir los mismos pasos para el NMOS unicamente teniendo en cuenta que los valores para PMOS de IH=170uA/um y IL=3pA/um manteniedo el valor de L=180nm. Al final obtenemos un valor de $R_{Peff}=59k\Omega$.

Para el cálculo de de la resistencia efectiva también está esta otra fórmula $R_{eff}=\frac{3ln(2)}{2}\frac{V_{DD}}{I_{dsat}}$. Ambas fórmulas son aceptables pero para este caso se uso el método recortado ya que es menos engorroso a la hora de calcular $\tau$ ya que de esta manera $\tau=RC$ eliminando de la ecuación el término de ln(2). LA ecuación con el término de ln(2) es util cuando no se quiere que llegar a VDD/2.

Ahora calcularemos las capacitancias equivalentes para el NMOS y el PMOS. De igual manera vamos a la hoja de datos para el cálculo de las capacitancias. Para esto usamos la siguiente ecuación:

$$
C_{gs}=W_{dib}L_{dib}C_{ox}+W_{dib}C_{ov}
$$

Empezando por el caso del NMOS tenemos un valor de $W_{dib}=0.22um$, de $L_{dib}=0.17um$, la capacitancia del óxido a 1,8V es $C_{ox}=8.46fF/um^2$ y por ultimo el valor de la capacitancia de traslape es de $C_{ov}=0.33fF/um$. Con esto obtenemos un valor de $C_{gs}=0.389fF$.

Para el transistor PMOS hacemos lo mismo que para el NMOS viendo la hoja de datos obtenemos que $C_{gs}=0.404fF$

Con este valor podemos calcular la constante RC, para NMOS $\tau=8.16E-12 s$, para PMOS $\tau=23.8E-12 s$

## Parte 2. Diseño de un inversor mínimo de tamaño óptimo

### Parte 2.A
Para esta parte se creó un esquemático con Custom Compiler.

#### Diseño de inversor esquemático

#### Simulaciones NMOS, PMOS e inversor

Usando el Spice Deck encontramos los valores de $I_{ds}$ vs $V_{ds}$ variando el valor de $V_{gs}$ para los transistores NMOS y PMOS. Para NMOS se usó W=220nm y para PMOS W=440nm, ambos con L=180nm. Graficando el barrido en DC obtenemos lo siguiente:

![NMOS](https://hackmd.io/_uploads/r1_e2raTa.png)

![PMOS](https://hackmd.io/_uploads/HJCz3BTTa.png)

Además se realizó un análisis transitorio para el inversor donde se logra observar la conmutación del inversor, para esto usamos los valores anteriores para NMOS y PMOS.

![inversor](https://hackmd.io/_uploads/ByH96Sp6p.png)

#### Simulación de las esquinas






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

## Parte 2.C

Para esta parte debemos usar el mismo tamaño de transistores que para las secciones anteriores que es un W=220nm para NMOS y W=440nm para PMOS, para ambos casos tenemos un L=180nm. Para esta sección haremos uso de las siguientes ecuaciones para el tiempo de fall and rise.

$$
\Delta t_{pdr}=\frac{3}{2}R_{p}C
$$

$$
\Delta t_{pdf}=3R_{n}C
$$

Para el cálculo de estas ecuaciones y obtener el valor de la resistencia efectiva para PMOS y NMOS necesitamos el valor de $\Delta t_{pdf}$ y $\Delta t_{pdr}$ para esto haremos uso de los valores de h para el fan-out, para este caso usamos el valor de h=3 y h=4, apoyándonos de la simulación en Hspice obtenemos que los valores para h=4 son $t_{pdf}=7,666E-11$ y $t_{pdr}=1.169E-10$. Para h=3 corremos la simulación y obtenemos los siguientes valores $t_{pdr}=9.443E-11$ y $t_{pdf}=6.297E-11$. Ahora podemos calcular los valores de los deltas para lo que obtenemos lo siguiente:

$$
\Delta t_{pdr}=2.247E-11\; s
$$

$$
\Delta t_{pdf}=1.369E-11\; s
$$

Ahora cumpliendo con las ecuaciones planteadas al inicio de esta sección, usando los valores de capacitancia obtenidos en la parte 1 de este documento obtenemos que para la resistencia efectiva para NMOS es de $R_{n}=11730 \Omega \approx 12k\Omega$. El valor para PMOS es de $R_{p}=37079\Omega\approx37k\Omega$.

Teniendo cuenta la diferencia que hay consideramos que es más acertado guiarse por los datos obtenidos en esta sección ya que poseemos más información de los tiempos de levantamiento y de caída gracias a los modelos de SPICE que utilizamos. 

