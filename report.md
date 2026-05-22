---
title: "Tarea No. 2"
subtitle: "Comprendiendo el Comportamiento del Consumidor a través de Modelos de Elección Discreta"
author: "Matías Arriagada R."
date: "Mayo 2026"
geometry: margin=1in
fontsize: 11pt
fontfamily: mathpazo
header-includes: |
  \usepackage{fancyhdr}
  \pagestyle{fancy}
  \fancyhead[L]{Tarea 2: Análisis de Elección del Consumidor}
  \fancyhead[R]{Universidad de Concepción}
  \fancyfoot[C]{\thepage}
  \usepackage{booktabs}
  \usepackage{graphicx}
  \usepackage{float}
  \floatplacement{figure}{H}
  \floatplacement{table}{H}
  \usepackage{hyperref}
  \hypersetup{colorlinks=true, linkcolor=blue, urlcolor=blue}
---

\newpage

# A. Identificación del Fenómeno de Estudio

En la economía digital moderna, la etapa final de cualquier transacción de comercio electrónico —el proceso de pago (checkout)— representa un punto crítico tanto para consumidores como para comerciantes. En este momento, los consumidores deben hacer una elección discreta respecto a cómo liquidar su transacción. Este estudio modela la **Elección del Método de Pago** realizada por los consumidores en una plataforma de e-commerce.

Comprender el comportamiento del consumidor en las elecciones de métodos de pago tiene profundas implicaciones prácticas y teóricas:
1. **Optimización Financiera para Comerciantes**: Diferentes métodos de pago conllevan distintas tarifas de transacción (tasas de descuento para comerciantes) y costos de procesamiento. Al comprender la sensibilidad del consumidor a las características del pago, los comerciantes pueden diseñar incentivos (por ejemplo, descuentos para métodos específicos) para orientar a los usuarios hacia opciones de menor costo.
2. **Optimización del Checkout y Tasas de Conversión**: La velocidad de la transacción y la seguridad son determinantes clave del abandono del carrito. Analizar cómo diferentes grupos demográficos valoran el tiempo frente a la seguridad ayuda a rediseñar la interfaz de pago para reducir la fricción.
3. **Diseño de Productos y Marketing**: Las instituciones financieras y las plataformas fintech (como las billeteras digitales) pueden utilizar estos insights de comportamiento para optimizar sus propuestas de valor, ajustando las velocidades de transacción, características de seguridad o promociones de cashback para coincidir con perfiles demográficos objetivo.
4. **Modelación Econométrica y Conductual**: Desde una perspectiva de elección discreta, este fenómeno representa un clásico problema de maximización de utilidad donde las alternativas son mutuamente excluyentes y están definidas tanto por atributos específicos de la alternativa (costo, tiempo, seguridad) como por características específicas del individuo (edad, género, nivel de membresía).

Para ilustrar este fenómeno de elección, la siguiente tabla resume la estructura teórica y los atributos clave (trade-offs) a los que se enfrenta un consumidor al momento de pagar:

\begin{table}[H]
\centering
\caption{Características Teóricas del Conjunto de Elección (Checkout)}
\begin{tabular}{lcccc}
\toprule
\textbf{Método de Pago} & \textbf{Tipo / Nido} & \textbf{Fricción (Tiempo)} & \textbf{Tarifa Relativa} & \textbf{Seguridad Percibida} \\
\midrule
Tarjeta de Crédito & Tarjeta Bancaria & Media (2.0s) & Alta (2.0\%) & Muy Alta (9.0/10) \\
Tarjeta de Débito & Tarjeta Bancaria & Alta (2.5s) & Baja (0.5\%) & Media (8.0/10) \\
PayPal & Billetera Digital & Muy Alta (4.0s) & Muy Alta (3.0\%) & Muy Alta (9.5/10) \\
UPI / Billetera & Billetera Digital & Baja (1.5s) & Nula (0.0\%) & Alta (8.5/10) \\
\bottomrule
\end{tabular}
\end{table}

**Alcance de este Estudio:** Este análisis se enfoca exclusivamente en la categoría de **Electrónica**. Los productos electrónicos representan compras de alto valor y alta implicación, donde la seguridad del pago y la fricción de la transacción son preocupaciones primordiales para los consumidores.

---

# B. Selección y Fuente de Datos

El análisis se basa en un conjunto de datos completo de las transacciones de una plataforma de comercio electrónico. Los datos están divididos en dos tablas relacionales principales:
1. **Datos de Órdenes (`orders.csv`)**: Captura información a nivel de transacción, incluyendo `order_id`, `customer_id`, `total_amount_usd`, el `payment_method` elegido, `order_status`, `delivery_days`, `session_duration_minutes`, `pages_viewed_before_purchase` y `customer_rating`.
2. **Datos de Clientes (`customers.csv`)**: Captura información de perfil demográfico e histórico para cada usuario, incluyendo `customer_id`, `country`, `age`, `gender`, `membership_tier` (Gratis, Plata, Oro, Platino) y patrones históricos de compra (ej. `total_spend_usd`, `total_orders`).

Para preparar el conjunto de datos para la modelación de elección discreta, fusionamos las dos tablas bajo la clave común `customer_id`. El conjunto de datos fusionado resultante contiene todos los componentes necesarios de la teoría de elección discreta:
- **Alternativas Mutuamente Excluyentes (Conjunto de Elección)**: El conjunto de métodos de pago disponibles en la caja. Nos enfocamos en las 4 opciones principales: **Tarjeta de Crédito**, **Tarjeta de Débito**, **PayPal** y **UPI / Billetera Digital**.
- **La Variable de Elección**: El método de pago real seleccionado por el usuario para esa transacción específica.
- **Atributos Específicos de la Alternativa**:
  - **Tarifa de Transacción (`fee_usd`)**: El costo directo incurrido. Lo calculamos como un porcentaje del valor total del pedido: Tarjeta de Crédito (2.0%), Tarjeta de Débito (0.5%), PayPal (3.0%) y UPI / Billetera Digital (0.0%).
  - **Tiempo de Procesamiento (`processing_time`)**: Duración promedio del checkout/liquidación en segundos: Tarjeta de Crédito (2.0s), Tarjeta de Débito (2.5s), PayPal (4.0s) y UPI / Billetera Digital (1.5s).
  - **Puntuación de Seguridad (`security_score`)**: Nivel de seguridad y protección percibido en una escala del 1 al 10: Tarjeta de Crédito (9.0), Tarjeta de Débito (8.0), PayPal (9.5) y UPI / Billetera Digital (8.5).
- **Características del Tomador de Decisiones**: Características individuales provenientes del perfil del cliente: `age` (edad), `gender` (género) y `membership_tier` (nivel de membresía).

---

# C. Análisis Exploratorio de Datos (EDA)

Se realizó un Análisis Exploratorio de Datos exhaustivo en R para comprender las distribuciones, correlaciones y estructuras generales dentro de nuestra muestra.

### 1. Distribución de la Elección de Pago (Cuotas de Mercado)

La Tabla 1 muestra la frecuencia y la cuota de mercado de los métodos de pago seleccionados dentro de la muestra limpia.

\begin{table}[H]
\centering
\caption{Distribución de la Elección del Método de Pago (Muestra de Electrónica)}
\begin{tabular}{lrr}
\toprule
Método de Pago & Frecuencia & Cuota de Mercado (\%) \\
\midrule
Tarjeta de Crédito & 1,548 & 43.07\% \\
Tarjeta de Débito & 908 & 25.26\% \\
PayPal & 713 & 19.84\% \\
UPI / Billetera Digital & 425 & 11.83\% \\
\bottomrule
\end{tabular}
\end{table}

Las Tarjetas de Crédito dominan el mercado de electrónica con una cuota del 43.07%, seguidas por las Tarjetas de Débito (25.26%) y PayPal (19.84%). UPI / Billetera Digital es el método menos elegido, con una cuota de mercado del 11.83%.

### 2. Demografía y Valores de Órdenes a través de los Grupos de Elección

Para identificar si las elecciones de pago varían sistemáticamente con las características individuales, resumimos los perfiles de los clientes por el método de pago elegido en la Tabla 2.

\begin{table}[H]
\centering
\caption{Promedios de Características Individuales por Método de Pago Elegido}
\begin{tabular}{lrrrrr}
\toprule
Método de Pago & Edad Promedio & Pct. Mujeres & Orden Promedio (USD) & Duración Sesión (min) & Páginas Vistas \\
\midrule
Tarjeta de Crédito & 35.7 & 50.0\% & \$247.1 & 17.1 & 6.4 \\
Tarjeta de Débito & 35.9 & 48.9\% & \$261.2 & 17.4 & 6.2 \\
PayPal & 35.3 & 51.2\% & \$257.5 & 16.7 & 6.5 \\
UPI / Billetera Digital & 35.7 & 53.2\% & \$271.8 & 17.2 & 6.5 \\
\bottomrule
\end{tabular}
\end{table}

Una observación clave de la Tabla 2 es la notable homogeneidad de los promedios en los grupos de elección dentro del segmento de electrónica. La edad promedio se mantiene prácticamente constante en alrededor de 35.5 años. De manera crucial, el valor promedio del pedido es significativamente mayor que el promedio general de la tienda (\$247 a \$271), reflejando la naturaleza de alto costo de la electrónica. Las duraciones de sesión web (~17 minutos) y páginas vistas (~6.4 páginas) se mantienen consistentes.

### 3. Elección de Pago por Nivel de Membresía

También verificamos si la membresía del programa de lealtad afecta la elección de pago. La Tabla 3 presenta las probabilidades de elección condicionadas al nivel de membresía del cliente.

\begin{table}[H]
\centering
\caption{Cuotas de Mercado de Métodos de Pago por Nivel de Membresía}
\begin{tabular}{lrrrr}
\toprule
Nivel de Membresía & Tarjeta Crédito & Tarjeta Débito & PayPal & UPI / Billetera Digital \\
\midrule
Gratis & 43.41\% & 24.38\% & 20.88\% & 11.33\% \\
Plata & 42.71\% & 24.92\% & 20.57\% & 11.80\% \\
Oro & 42.53\% & 25.74\% & 19.89\% & 11.84\% \\
Platino & 42.34\% & 27.28\% & 19.37\% & 11.01\% \\
\bottomrule
\end{tabular}
\end{table}

A medida que el nivel de membresía aumenta de Gratis a Platino, hay un ligero aumento en la participación de las elecciones de Tarjeta de Débito (de 24.38% a 27.28%) y una disminución menor en las elecciones de PayPal (de 20.88% a 19.37%). Las participaciones de Tarjeta de Crédito y UPI se mantienen estables.

### 4. Representatividad, Valores Faltantes y Análisis de Valores Atípicos

- **Representatividad**: La muestra representa una gran base de usuarios de e-commerce en múltiples países (con ventas principales de países como EE.UU., Alemania, Reino Unido, etc.). Representa a usuarios activos que completaron o devolvieron sus pedidos, lo cual es la población objetivo exacta para analizar las opciones de finalización de transacciones.
- **Valores Faltantes**: Analizamos la falta de datos en todas las variables. La única variable que contiene valores faltantes es `customer_rating` (calificación del cliente). Econométricamente, descartar observaciones debido a calificaciones faltantes reduciría sustancialmente nuestra muestra de estimación, introduciendo un posible sesgo de selección. Argumentamos que la calificación del cliente es una *variable de retroalimentación posterior a la compra* que ocurre después del checkout. No afecta la elección del método de pago en el momento de pagar. Por lo tanto, dado que no es un factor de confusión en nuestro modelo de elección, podemos omitirla de manera segura de las ecuaciones de utilidad y preservar la muestra completa de transacciones.
- **Valores Atípicos (Outliers)**:
  - `total_amount_usd` exhibe un valor máximo de \$2,730.88, que está lejos de la mediana. Sin embargo, estas son órdenes grandes válidas en un sitio de comercio electrónico (especialmente en electrónica) y no errores de ingreso de datos. Dado que las tarifas de transacción son lineales con la cantidad del pedido, estos montos más altos crean varianza útil en nuestro atributo calculado `fee_usd`.
  - `session_duration_minutes` muestra un máximo de 361 minutos. Esto es realista para usuarios que dejan pestañas abiertas durante sesiones de compra.
  - La edad de los clientes oscila entre 18 y 75 años, mostrando una distribución muy limpia y representativa de una población adulta que compra en línea.

---

# D. Definición de la Muestra de Estimación

Para establecer una muestra de estimación científicamente sólida para modelos de elección discreta, los registros originales de transacciones se filtraron según estrictos criterios econométricos:

1. **Filtro de Estado de Orden (Finalización de Transacción)**:
   - *Justificación*: Debemos modelar la elección realizada en un pago finalizado. Los pedidos con estado `Cancelled` (Cancelado) o `Processing` (Procesando) representan pagos incompletos o transacciones abortadas antes de confirmar la liquidación.
   - *Acción*: Se excluyeron todos los pedidos excepto aquellos marcados como `Delivered` (Entregado) o `Returned` (Devuelto).

2. **Filtro de Segmento por Categoría**:
   - *Justificación*: Enfocamos el análisis en un solo segmento de alta implicación para reducir la heterogeneidad no observada entre categorías de productos muy diferentes.
   - *Acción*: Se restringió la muestra exclusivamente a la categoría **Electrónica** (Electronics).

3. **Filtro de Definición del Conjunto de Elección (Popularidad de la Alternativa)**:
   - *Justificación*: Los modelos de elección discreta requieren conjuntos de elección bien definidos. Los métodos de pago menores como Transferencia Bancaria, Compra Ahora Paga Después y Criptomonedas son elegidos en muy pocas transacciones.
   - *Acción*: Se restringió el conjunto de elección a las cuatro alternativas dominantes: Tarjeta de Crédito, Tarjeta de Débito, PayPal y UPI / Billetera Digital.

4. **Muestra de Estimación Final**:
   - La muestra de estimación final contiene **3,594 observaciones limpias a nivel de transacción**. Este tamaño proporciona un poder estadístico sustancial para estimar tanto los modelos Logit Multinomial (MNL) como el Nested Logit.

---

# E. Modelo de Elección y Estimación Econométrica

Formulamos y estimamos modelos Logit Multinomial (MNL) en R utilizando la biblioteca `mlogit`.

### 1. Especificaciones del Modelo

#### Modelo 1: Modelo Solo de Atributos (Sin ASCs)
El Modelo 1 aísla el efecto de los atributos de pago (precio, velocidad, seguridad) al omitir constantes específicas de la alternativa. La utilidad que el individuo $i$ deriva de la alternativa $j$ es:
$$U_{ij} = \beta_{precio} \cdot \text{fee\_usd}_{ij} + \beta_{tiempo} \cdot \text{processing\_time}_j + \beta_{calidad} \cdot \text{security\_score}_j + \gamma_{j} \cdot X_i + \epsilon_{ij}$$
Aquí interactuamos características individuales $X_i$ (edad, género, membresía) con las opciones. UPI / Billetera Digital se utiliza como alternativa base.

#### Modelo 2: Modelo Completo con ASCs
El Modelo 2 incorpora Constantes Específicas de Alternativa ($ASC_j$) para capturar las preferencias base por cada método de pago que no se explican por las tarifas de transacción o covariables individuales.
$$U_{ij} = ASC_j + \beta_{precio} \cdot \text{fee\_usd}_{ij} + \gamma_{j} \cdot X_i + \epsilon_{ij}$$
Donde $ASC_{\text{Tarjeta de Crédito}}$ se normaliza a 0.

### 2. Resultados de la Estimación del Modelo

La Tabla 4 resume los coeficientes estimados para ambos modelos.

\begin{table}[H]
\centering
\caption{Resultados de la Estimación del Modelo Logit Multinomial}
\begin{tabular}{lrrrr}
\toprule
& \multicolumn{2}{c}{\textbf{Modelo 1 (Solo Atributos)}} & \multicolumn{2}{c}{\textbf{Modelo 2 (Con ASCs)}} \\
\textbf{Variable} & \textbf{Estimación} & \textbf{p-valor} & \textbf{Estimación} & \textbf{p-valor} \\
\midrule
$ASC_{\text{Tarjeta de Débito}}$ & -- & -- & -0.6674 & < 2e-16 *** \\
$ASC_{\text{PayPal}}$ & -- & -- & -0.7311 & < 2e-16 *** \\
$ASC_{\text{UPI}}$ & -- & -- & -1.4153 & < 2e-16 *** \\
Tarifa (USD) ($\beta_{precio}$) & -0.0045 & 0.508 & -0.0035 & 0.450 \\
Tiempo (s) ($\beta_{tiempo}$) & -0.2055 & 0.012 * & -- & -- \\
Seguridad ($\beta_{calidad}$) & 0.4656 & 0.0004 *** & -- & -- \\
\midrule
Log-Verosimilitud & \multicolumn{2}{c}{-4,627.04} & \multicolumn{2}{c}{-4,607.34} \\
AIC & \multicolumn{2}{c}{9,296.09} & \multicolumn{2}{c}{9,258.68} \\
\bottomrule
\end{tabular}
\end{table}

### 3. Modelo Nested Logit y Estructura

Para relajar el supuesto de Independencia de Alternativas Irrelevantes (IIA) inherente a los modelos MNL, estimamos un **Modelo Nested Logit**. Agrupamos las alternativas en dos nidos distintos según la fricción del pago y la tecnología subyacente:
1. **Nido de Tarjetas Bancarias Tradicionales**: Tarjeta de Crédito, Tarjeta de Débito. (Requiere ingresar números de tarjeta plástica de 16 dígitos).
2. **Nido de Billeteras Digitales**: PayPal, UPI / Billetera Digital. (Plataformas de terceros que permiten un pago en 1-clic o biométrico).

**Prueba de Razón de Verosimilitud (Likelihood Ratio Test: MNL vs Nested Logit)**:
Una prueba formal de Razón de Verosimilitud (LR) comparando el modelo MNL base con el modelo Nested Logit arrojó una estadística Chi-cuadrado de 37.906 en 1 grado de libertad, con un p-valor de **7.424e-10**.
Esto prueba definitivamente que la estructura anidada proporciona un ajuste enormemente superior para los datos de pago de productos electrónicos. Los consumidores agrupan los métodos de pago mentalmente por tipo de tecnología/fricción antes de elegir la marca específica.

### 4. Interpretación Econométrica y Disposición a Pagar (WTP)

- **Sensibilidad al Tiempo ($\beta_{tiempo}$)**: En el modelo base, el tiempo de procesamiento es negativo y estadísticamente significativo ($\beta = -0.2055, p = 0.012$). Transacciones más rápidas generan mayor utilidad.
- **Sensibilidad a la Seguridad ($\beta_{calidad}$)**: La puntuación de seguridad es positiva y altamente significativa ($\beta = 0.4656, p < 0.001$). Una mayor seguridad percibida es crucial para las compras de electrónica de alto costo.
- **Sensibilidad al Precio ($\beta_{precio}$)**: El coeficiente de la tarifa de transacción es negativo pero estadísticamente insignificante ($p = 0.508$).

**La Insignificancia del Precio y el Reto del WTP**:
Debido a que la sensibilidad al precio no puede distinguirse de cero en este conjunto de datos específico, cualquier WTP calculado (ej., $WTP_{tiempo} = \$44.97$) es estadísticamente inestable. Dividir un coeficiente significativo por un valor cercano a cero resulta en números de WTP volátiles. Esto resalta una lección crucial en el modelado aplicado de elección discreta: **la sensibilidad al precio debe identificarse de manera robusta** para que los cálculos del WTP tengan un significado económico válido.

---

# F. Conclusión

Este informe completó con éxito el análisis de las opciones de métodos de pago de los consumidores para **Electrónica**:
1. Identificamos el fenómeno de elección de pago y aislamos una muestra limpia de 3,594 transacciones de productos electrónicos.
2. Estimamos modelos Logit Multinomial base, confirmando que la velocidad de pago y la seguridad son impulsores significativos de utilidad.
3. Formulamos y estimamos exitosamente un **Modelo Nested Logit** separando Tarjetas Tradicionales de Billeteras Digitales, probando a través de una prueba LR (p < 0.0001) que los consumidores emplean un proceso de toma de decisiones explícitamente anidado.
4. Descubrimos las limitaciones econométricas de calcular la Disposición a Pagar (Willingness-to-Pay) cuando el numerario (precio) está débilmente identificado.
