# EL GOAT --- Documento de diseño y contexto para implementación

> **Propósito:** consolidar las decisiones de diseño, las cuestiones
> pendientes y el alcance del próximo bloque de trabajo. Este documento
> sirve como contexto para conversaciones futuras y para preparar una
> consulta acotada a MiMo antes de modificar código.
>
> **Estado:** documento de diseño previo a implementación. No implica
> que las decisiones pendientes estén cerradas ni autoriza cambios de
> código, refactors, instalaciones, ejecución de pruebas o commits.

## 1. Visión del proyecto

**EL GOAT** es un juego indie de carrera futbolística inspirado en
*Copero* y *New Star Soccer / Ídolo*. El fútbol es el núcleo; la
narrativa y la capa social complementan la experiencia.

Principio de diseño: **"se juega un poco → se decide bastante"**. Las
decisiones del jugador deben importar: el posicionamiento y el momento
del movimiento crean oportunidades; los atributos afectan posibilidades
y ejecución, pero no reemplazan la habilidad ni garantizan resultados.
El azar aporta incertidumbre, como condimento, sin dominar la
experiencia.

La idea es que las situaciones futbolísticas sean momentos jugables
dentro de un partido emulado, no una colección de minijuegos sin
relación. Las decisiones sociales pueden alterar condiciones y
relaciones que influyen en situaciones posteriores.

## 2. Alcance y fases del juego

### 2.1. Laboratorio actual

El laboratorio es una **herramienta de desarrollo y prueba**, no la
experiencia final que verá el usuario. Hoy hay un menú de opciones que
permite seleccionar el desmarque y no mucho más.

Objetivos del laboratorio: - Construir situaciones jugables
individualmente. - Poder seleccionar e iniciar cada situación de forma
independiente. - Probar controles, atributos, presión, resolución de
acciones y feedback. - Repetir escenarios con condiciones
configurables. - Validar las piezas antes de conectarlas en una
experiencia continua.

Cuando exista una cantidad suficiente de situaciones probadas, se
orquestarán dentro de la carrera y el laboratorio dejará de ser una
opción visible para el jugador. Podrían conservarse herramientas
internas de desarrollo, si resultan útiles.

### 2.2. Inicio previsto de una carrera (fase 0 / MVP narrativo)

La fase 0 es el comienzo de cada carrera en el juego completo, no un
tutorial descartable. Tiene la intención de funcionar como una versión
reducida que adelanta el tipo de experiencia que vendrá después.

Premisa: ojeadores de distintos lugares llegan al pueblo o ciudad del
jugador para hacer pruebas y seleccionar futbolistas. El protagonista es
un candidato más; no tiene garantizado convertirse en estrella.

-   Hay **dos días obligatorios** de pruebas.
-   Cada día representa un partido emulado mediante un conjunto de
    situaciones futbolísticas jugables y situaciones
    narrativas/sociales.
-   Puede haber un **tercer día** si el rendimiento de los dos primeros
    días es suficientemente bueno. Es una oportunidad adicional para
    demostrar potencial, no una garantía de éxito.
-   No acceder al tercer día no significa fracasar: el jugador sigue
    recibiendo ofertas de clubes.
-   Al terminar la fase 0 siempre se presentan **exactamente tres
    ofertas de clubes** de magnitud relativamente similar. El jugador
    elige dónde comenzar.
-   El nivel de los clubes depende del rendimiento y el potencial
    globales. Un rendimiento excepcional podría atraer a un club de
    primer nivel; uno más modesto, a clubes más modestos. No debe haber
    una oferta claramente superior a las otras dos por diseño.
-   Tras elegir club, la carrera continúa en el contexto
    correspondiente, por ejemplo, una liga determinada.

**Importante:** la fórmula de evaluación, los umbrales para acceder al
tercer día, la generación de ofertas y el peso de los factores siguen
pendientes.

### 2.3. Situaciones sociales y narrativa

La capa social complementa el fútbol, pero no debe pesar más que el
rendimiento futbolístico en la evaluación global.

-   Las situaciones suelen ofrecer dos opciones; una tercera se usa solo
    si aporta algo.
-   Las decisiones tienen ventajas y desventajas; no debe existir
    siempre una opción universalmente correcta.
-   Ejemplo ilustrativo: salir con compañeros la noche previa puede
    gastar energía, pero mejorar relaciones y aumentar la predisposición
    de los compañeros a pasar el balón. Quedarse descansando preserva
    energía, pero no mejora esas relaciones.
-   Una salida podría incluir una pequeña posibilidad de encontrarse con
    un ojeador, o una oportunidad inesperada de ayudar a alguien.
-   Los eventos, diálogos y consecuencias concretas todavía deben
    diseñarse.

El azar puede abrir oportunidades, pero el fútbol debe ser el factor
principal.

## 3. Flujo inicial del jugador: decisión confirmada

El flujo inicial acordado para la etapa actual es:

1.  Al iniciar el juego, se muestra el **creador de jugador**.
2.  El usuario ingresa nombre, apellido, dorsal preferido y perfil
    inicial.
3.  Al confirmar, se crea una única representación del jugador para la
    sesión.
4.  Se pasa directamente al **laboratorio**.
5.  El usuario puede cambiar de situación dentro del laboratorio, pero
    no vuelve al creador durante esa sesión.
6.  No habrá guardado de partidas en esta etapa. Al reiniciar el juego,
    se vuelve al creador y comienza una nueva sesión.
7.  Todas las situaciones de la sesión deben usar los mismos datos y
    atributos del jugador; no se crea un jugador nuevo al cambiar de
    situación.

En el juego completo, el creador se conservará, pero después de crear al
jugador el flujo avanzará hacia las pruebas de selección, no hacia el
laboratorio.

### Datos del creador

**Confirmado como intención:** - Nombre. - Apellido. - Dorsal
preferido. - Perfil inicial.

**Pendiente de decidir:** - Validaciones de campos y límites de
caracteres. - Si el dorsal puede repetirse o qué restricciones tiene. -
Presentación visual y navegación exacta. - Si se muestra un resumen de
atributos antes de confirmar. - Si se permitirá cambiar de perfil o
atributos desde una herramienta de desarrollo interna, sin exponerlo
como opción normal del jugador.

## 4. Perfiles y atributos

### 4.1. Los seis atributos

1.  **Velocidad:** capacidad física para desplazarse rápido. Por ahora
    es la misma con y sin balón. No representa la decisión de hacia
    dónde moverse.
2.  **Movimiento:** encontrar espacios útiles, realizar desmarques
    efectivos y ofrecer líneas de pase. Influye en la calidad de las
    carreras, pero no mueve automáticamente al jugador ni decide la
    dirección por él.
3.  **Visión:** reconocer y evaluar opciones: compañeros libres, líneas
    de pase y espacios. Puede influir en ayudas visuales para destacar
    opciones prometedoras; no elige ni ejecuta automáticamente.
4.  **Pase:** calidad de ejecución del pase, dirección, precisión y
    entrega.
5.  **Regate:** control del balón, cambios de dirección y capacidad de
    superar rivales, incluyendo amagues.
6.  **Definición:** calidad de ejecución del remate.

Aceleración y otros matices físicos/técnicos no son atributos
independientes por ahora. La aceleración se considera común/técnica
hasta que exista una razón clara para separarla.

### 4.2. Perfiles iniciales

Hay cuatro perfiles propuestos/aceptados, con el mismo presupuesto total
de atributos para evitar que uno sea globalmente más poderoso por tener
más puntos.

  -----------------------------------------------------------------------
  Perfil            Atributos         Atributo          Identidad
                    principales       secundario        esperada
  ----------------- ----------------- ----------------- -----------------
  **Creador**       Visión y Pase     Movimiento        Reconoce opciones
                                                        y distribuye
                                                        mejor

  **Regateador**    Regate y          Movimiento        Puede atacar
                    Velocidad                           espacios y
                                                        resolver con el
                                                        balón

  **Definidor**     Definición y      Velocidad         Encuentra
                    Movimiento                          posiciones de
                                                        remate y finaliza

  **Equilibrado**   Ninguno dominante Reparto bastante  Versatilidad sin
                                      parejo            una especialidad
                                                        extrema
  -----------------------------------------------------------------------

La especialización debe ser perceptible desde el comienzo, pero
moderada: aproximadamente **3--4 sobre 10** de intensidad. Un perfil
tiene fortalezas claras, pero no debe convertirse en una elección
objetivamente superior. Las cifras exactas y las distribuciones todavía
deben definirse.

El perfil Equilibrado tendrá una distribución fija, no aleatoria en cada
partida. Puede tener uno o dos atributos levemente más altos sin perder
su identidad equilibrada.

### 4.3. Progresión y libertad

-   Los perfiles no restringirán la evolución futura: durante la
    carrera, el jugador podrá desarrollar cualquier atributo.
-   La afinidad por los atributos fuertes podría facilitar su
    desarrollo, pero no habrá bloqueos rígidos.
-   La progresión se piensa gradual.
-   No se planean desbloqueos especiales al alcanzar umbrales por ahora.
-   **No habrá crecimiento de atributos durante el MVP de tres días.**

La progresión es una idea para el juego completo, no parte del primer
bloque.

### 4.4. Cómo deben influir los atributos

Los atributos no son independientes del contexto. Espacio, posiciones,
presión, dirección, timing y atributos rivales afectan el resultado. Por
ejemplo, un buen regateador puede tener problemas contra un rival veloz;
no basta con empujar el balón hacia delante y correr.

Cada acción debería tener un atributo principal y, cuando corresponda,
otros factores secundarios claramente justificados. No hacer que todos
los atributos afecten mecánicamente a todas las acciones sin una razón
comprensible.

Distinguir siempre: - **Calidad de decisión:** si la opción elegida era
razonable en ese contexto. - **Calidad de ejecución:** qué tan bien se
ejecutó. - **Resultado:** qué ocurrió finalmente.

Una decisión inteligente puede terminar mal por una buena intervención
rival o por incertidumbre. Un desmarque puede crear espacio para un
compañero aunque el balón no llegue al jugador que se movió.

### 4.5. Control del jugador

-   **Movimiento y regate:** control directo del usuario. El usuario
    decide dirección, timing y cambios de dirección; el atributo influye
    en control y dificultad, no sustituye la acción.
-   **Pase y remate:** se busca comenzar con controles relativamente
    simples, elección explícita de acción y dirección/opción. Los
    detalles de controles están pendientes.
-   No resolver todos los duelos como una tirada automática de
    atributos.

**Idea futura, fuera del primer bloque:** un presupuesto compartido de
esfuerzo por jugada para evitar correr/regatear indefinidamente. Correr
intensamente, cambiar de dirección repetidamente o encadenar regates
podría consumirlo; habría efectos de agotamiento y recuperación entre
jugadas. Este sistema queda expresamente para más adelante.

## 5. Evaluación del rendimiento

### 5.1. Principios

La evaluación debe valorar por separado decisión, ejecución y resultado.
No usar un resultado binario de éxito/fracaso ni premiar solo el
desenlace.

Ejemplos: - Un pase progresivo inteligente interceptado puede recibir
buena valoración de decisión. - Un desmarque que arrastra a un rival y
abre espacio para otro compañero debe reconocer ese aporte aunque no
reciba el balón. - Una acción técnicamente correcta puede haber sido una
mala decisión contextual.

### 5.2. Propuesta provisional

Se propuso comenzar con tres componentes con peso inicial igual (un
tercio cada uno): - Decisión. - Ejecución. - Resultado.

Esto es **provisional** y debe revisarse con pruebas y estadísticas. No
fijar aún fórmulas ni umbrales definitivos.

La evaluación inicial debería basarse en reglas explícitas y
observables, no en una "IA" opaca que pretende juzgar fútbol de manera
general. Criterios posibles: separación respecto de rivales, espacio
útil, línea de pase, avance hacia zonas progresivas y dificultad de la
ejecución. Evitar contar dos veces el mismo mérito.

### 5.3. Feedback al usuario

-   El jugador no ve una nota numérica por acción ni una calificación
    tipo "8/10".
-   La puntuación permanece interna.
-   El jugador interpreta cómo va el partido por comentarios
    contextuales, reacciones y consecuencias.
-   Frecuencia intermedia: feedback en intervenciones cuando
    corresponde; comentarios más expresivos solo en momentos destacados.
    Silencios y murmullos también ayudan a dar naturalidad.
-   La reacción no debe mapear de manera obvia una frase a una
    puntuación fija. Debe existir variedad de frases para evitar que el
    jugador decodifique una nota oculta.

Ejemplos ilustrativos, no texto final: - Buen pase filtrado: "¡Buena!",
"¡Linda pelota!", "¡Uhhh, qué pelota!". - Intento inteligente
interceptado: "¡Ahh, era buena!". - Decisión apresurada con tiempo
disponible: "¡Tranquilo, tenías tiempo!". - Compañero alentando: "¡Bien,
ya va a salir!".

Para el primer bloque basta un cuadro de texto sencillo. No son
necesarios audio ni animaciones.

**Ideas futuras:** murmullos de tribuna, voces, reacciones de
compañeros, audio, texto animado y reacciones visuales de
personajes/público. No hace falta animar a cada persona.

## 6. Feedback visual y ayudas

Las ayudas visuales deben hacer que las opciones sean más comprensibles,
no tomar decisiones por el jugador.

-   Para el MVP, las ayudas pueden ser relativamente evidentes al
    principio.
-   Ejemplo: cuando hay varias opciones de pase, un compañero que
    realiza un desmarque especialmente prometedor podría destacarse con
    color o brillo.
-   La opción resaltada es una sugerencia contextual, no una garantía de
    éxito.
-   La intensidad de las ayudas podría ajustarse más adelante.
-   Cada atributo debe tener efectos perceptibles; usar señales visuales
    cuando aporten claridad, pero no es necesario que todos tengan una
    ayuda visual propia en la primera iteración.

El alcance visual concreto del primer bloque queda sujeto a la revisión
de la arquitectura y al tamaño de la tarea.

## 7. Situaciones futbolísticas: catálogo de trabajo

La prioridad actual es construir y probar situaciones una por una. La
lista es una guía de posibilidades, no una especificación cerrada.

### 7.1. Situaciones existentes / prioridad inmediata

-   Desmarque con presión.
-   Movimiento sin balón y creación de líneas de pase.
-   Pase y calidad de la línea de pase.
-   Resultado de pase: preciso, desviado o interceptado.
-   Presión de rivales y contexto espacial.

El primer bloque debería partir de lo que ya existe, no reescribirlo de
entrada.

### 7.2. Situaciones candidatas para el laboratorio

**Desmarque** - Buscar espacio libre. - Ofrecer línea de pase. - Atacar
profundidad. - Desmarcarse con presión cercana. - Arrastrar a un rival
para abrir espacio a un compañero.

**Pase** - Elegir destinatario. - Encontrar línea de pase libre. - Pase
progresivo bajo presión. - Pase corto y pase al espacio. - Evaluar
precisión, desviación e intercepción.

**Regate (futuro)** - Proteger el balón. - Cambiar de dirección. -
Amagar. - Superar un rival. - Aprovechar un espacio. - Resolver un duelo
contra un rival con atributos diferentes.

**Definición (futuro)** - Encontrar posición de remate. - Elegir
dirección. - Ejecutar el remate. - Rematar bajo presión.

**Combinaciones (futuro)** - Desmarque + pase. - Recepción + regate. -
Pase + remate. - Secuencias más largas una vez probadas las acciones
individuales.

Una variante de una situación existente (por ejemplo, más presión rival)
no necesariamente es una situación nueva. Una secuencia que agrega
decisiones diferentes puede ser una situación combinada.

### 7.3. Alcance futbolístico actual

Las situaciones actuales son **ofensivas** y el jugador representa un
mediapunta o delantero. No se contemplan situaciones defensivas
controladas por el usuario en el MVP inicial; se dejan para después.

Regate y remate no están implementados aún. No incluirlos en el primer
bloque salvo que se acuerde explícitamente una ampliación.

## 8. Orquestación futura

La orquestación comienza cuando las situaciones estén suficientemente
probadas.

-   Cada día de selección debe sentirse como un partido emulado, no como
    una sucesión arbitraria de minijuegos.
-   Se combinarán situaciones futbolísticas controladas por el jugador
    con eventos de fondo acotados y coherentes.
-   El contexto (marcador, tiempo y estado del partido) entra a una
    situación; la situación devuelve un resultado y consecuencias. No
    debe contener el estado completo del partido.
-   Las decisiones sociales previas pueden afectar energía, relaciones y
    condiciones de situaciones posteriores.
-   Se deben elegir qué situaciones se juegan y cuáles se simulan
    automáticamente.
-   La dificultad y el riesgo deben evitar rachas injustas o una
    sensación de perder por azar.
-   La evaluación global conecta el rendimiento con el acceso al tercer
    día y el nivel de las tres ofertas.

Estas reglas son objetivos de diseño futuros, no tareas del primer
bloque.

## 9. Primer bloque de implementación propuesto

### Objetivo

Conectar el creador de jugador, los perfiles/atributos y el laboratorio
actual sin intentar construir todavía la carrera completa.

### Orden de trabajo propuesto

1.  **Inspeccionar la arquitectura existente antes de modificar
    archivos.** Identificar flujo de escenas, menú actual, catálogo de
    situaciones, definición de situaciones, estado del jugador, scripts
    que coordinan las fases y pruebas existentes.
2.  Proponer un plan de integración pequeño, con archivos a
    crear/modificar y dependencias.
3.  Revisar el plan antes de autorizar cambios.
4.  Implementar el creador y el paso directo al laboratorio.
5.  Mantener un único jugador en memoria durante la sesión.
6.  Introducir los cuatro perfiles con presupuestos iguales y
    distribuciones moderadas.
7.  Integrar efectos perceptibles de atributos en el desmarque y el pase
    existentes, priorizando Movimiento, Visión y Pase.
8.  Agregar feedback contextual simple si encaja en el alcance.
9.  Añadir o adaptar pruebas automatizadas de acuerdo con la
    arquitectura existente, sin inventar un sistema de tests nuevo antes
    de conocer el actual.
10. Entregar resumen, archivos modificados, pruebas afectadas, riesgos y
    cuestiones pendientes.

### Fuera de alcance de este bloque

-   Implementar regate y definición desde cero.
-   Crear todas las situaciones candidatas de una sola vez.
-   Diseñar e implementar la carrera completa y su orquestación.
-   Crear los días de selección y eventos sociales.
-   Implementar evaluación global, umbrales y generación de ofertas de
    clubes.
-   Implementar progresión de atributos.
-   Implementar esfuerzo/fatiga.
-   Crear audio, animaciones de público o reacciones complejas.
-   Guardado/carga de partidas.
-   Refactor estructural amplio sin evidencia de que sea necesario.

## 10. Arquitectura y pruebas: preguntas pendientes antes de codificar

El proyecto ya cuenta con pruebas para acciones y existe una tarea
configurada en VS Code para ejecutarlas. Hay que tenerlo en cuenta al
decidir la integración.

Antes de cambiar la arquitectura, obtener una descripción basada en el
contexto ya disponible en MiMo: - Qué archivos y carpetas hay y qué
responsabilidad tiene cada uno. - Qué archivo representa o coordina el
flujo de escenas. - Cómo se seleccionan y configuran las situaciones del
laboratorio. - Dónde se mantienen el estado de una situación y el estado
compartido del jugador. - Cómo están modelados `SituationDefinition` y
el catálogo de situaciones. - Qué tests existen, cómo están organizados
y qué comportamiento cubren. - Qué tarea de VS Code ejecuta la suite y
qué comandos/convenciones de tests conoce el proyecto. - Qué
dependencias existen entre scripts y escenas. - Qué problemas
estructurales concretos se observan, si los hay, y qué evidencia los
demuestra. - Si es razonable añadir el creador y los atributos sobre la
arquitectura actual o si conviene reorganizar primero algo puntual.

**Regla de proceso:** primero pedir una explicación y un mapa de
arquitectura; luego evaluar si la estructura actual alcanza. No decidir
un refactor antes de conocer el estado real del proyecto. No pedirle a
MiMo que recorra todo el repositorio ni que haga cambios durante esa
consulta.

### Tests

-   Las pruebas existentes son parte de la arquitectura y deben
    preservarse.
-   Antes de implementar, identificar qué pruebas cubren cada acción y
    qué nuevas pruebas harían falta para el creador, los perfiles y los
    efectos de atributos.
-   Al terminar una tarea, informar qué tests se ejecutaron y cuáles
    quedaron pendientes.
-   El usuario ejecuta las pruebas localmente mediante su tarea de VS
    Code.
-   MiMo no debe intentar ejecutar pruebas, instalar dependencias,
    reparar Godot ni modificar el entorno local. Debe diseñar y
    modificar el código de acuerdo con las convenciones de tests que
    encuentre en el contexto.
-   No afirmar que las pruebas pasaron si el usuario no las ejecutó o no
    compartió el resultado.

## 11. Estado técnico conocido (contexto previo; confirmar con el mapa de arquitectura)

Proyecto: `D:\Projects\el-goat-game`. Motor indicado por el usuario:
Godot 4.7.2.

El usuario indicó que las tareas T1--T5 estaban implementadas, probadas,
commiteadas y subidas. En ese momento, el árbol de trabajo estaba limpio
y la rama `master` seguía a `origin/master`. Esto es información
histórica y debe confirmarse antes de asumir que el estado sigue igual.

Commits mencionados: -
`05d6adf feat: implement pass resolution outcomes and integrate lane quality into pass precision` -
`02b6c2a feat: add evaluate_pass_lane method to assess pass line quality against rivals` -
`b11cd03 feat: implement configurable holder movement for teammate during off-ball phase`

Detalles técnicos mencionados anteriormente: - `player.gd`:
`CharacterBody2D`; `MAX_SPEED := 240.0`, `ACCELERATION := 600.0`,
`DECELERATION := 800.0`; el movimiento usa entrada direccional,
`velocity.move_toward` y `move_and_slide()`. - `main.gd` coordina una
secuencia de estados: `OFF_BALL` (\~2 s) → `PASS` → `RESULT`; detiene la
velocidad del jugador y reinicia la situación. - Las situaciones se
configuran mediante `SituationDefinition`. - Parámetros del catálogo
mencionados: `off_ball_duration=2.0`, `restart_interval=1.0`,
`ball_speed=350.0`, `teammate_pass_precision=0.72`,
`pass_lead_distance=72.0`, `maximum_pass_error=80.0`,
`ball_contact_distance=25.0`, `interception_distance=15.0`,
`ball_outside_grace_duration=0.5`, `holder_shift_distance=0.0`,
`holder_shift_speed=60.0`, `rival_count=1`, `rival_speed=115.0`,
`minimum_initial_rival_distance=150.0`, más regiones normalizadas. -
`FOOTBALL_DESIGN.md` describe la mitad ofensiva, el arco rival arriba y
la línea de medio campo abajo; una situación con jugador sin balón,
compañero con balón y uno o más rivales. - La selección de situaciones
funciona como laboratorio; no hay bloqueo de progresión. - La zona de
pase no apunta simplemente a la posición actual del jugador: considera
dirección/velocidad, separación del compañero, espacio respecto del
rival, profundidad y precisión configurada. - El prototipo usa
heurísticas; la evaluación táctica definitiva aún no está
implementada. - En la escena se usan formas visuales para jugador,
compañero y rivales, sin cuerpos de colisión ni animaciones. - Regate,
remate y control/conducción de balón no están implementados.

No tomar estos detalles como garantía del estado actual: usarlos como
pistas para orientar las preguntas y confirmar lo necesario sin pedir un
barrido completo.

## 12. Pendientes de diseño, separados por tema

### Antes o durante el primer bloque

-   Distribución numérica exacta de los seis atributos para cada perfil.
-   Escala de atributos y reglas de validación.
-   Presentación y validaciones del creador.
-   Qué efectos concretos de Movimiento, Visión y Pase entran en la
    primera iteración.
-   Qué feedback contextual mínimo se implementa ahora.
-   Qué pruebas actuales cubren las acciones y cuáles hay que
    adaptar/agregar.
-   Si la arquitectura actual permite integrar el creador y el jugador
    compartido sin refactor.

### Para después del primer bloque

-   Controles exactos de pase, regate y remate.
-   Fórmulas y pesos definitivos de evaluación.
-   Criterios para acceso al tercer día y generación de clubes.
-   Selección de situaciones jugables frente a eventos simulados.
-   Sistema de fatiga/esfuerzo.
-   Progresión de atributos.
-   Situaciones defensivas.
-   Contenido y consecuencias de eventos sociales.
-   Presentación visual/audio y variedad de reacciones.
-   Guardado y carga.
-   Herramientas internas para ajustar perfiles y condiciones de
    situaciones.

### Ideas opcionales para conservar

-   Ayudas visuales de visión configurables en intensidad.
-   Variantes de perfiles equilibrados en el futuro.
-   Afinidad de progresión para atributos fuertes sin bloquear el
    desarrollo de otros.
-   Encuentros aleatorios con ojeadores/personajes durante eventos
    sociales.
-   Reacciones de compañeros, murmullos, voz y público.
-   Esfuerzo compartido por jugada con agotamiento y recuperación.
-   Variantes de situaciones por presión, espacio, rivales y contexto de
    partido.

## 13. Reglas de colaboración con MiMo / OpenCode

-   No implementar todavía durante la primera consulta de arquitectura.
-   No recorrer exhaustivamente todo el repositorio: responder primero
    con el contexto que ya tenga disponible y marcar explícitamente qué
    sabe, qué infiere y qué desconoce.
-   No inventar nombres de archivos, rutas, scripts, escenas ni tests.
-   Si un dato no está en contexto, decir "no lo tengo en contexto" en
    lugar de adivinar.
-   Presentar responsabilidades y dependencias con claridad, idealmente
    un mapa breve de archivos/escenas y flujo de ejecución.
-   No proponer un refactor grande sin señalar el problema concreto y la
    evidencia.
-   No ejecutar tests, instalar o reparar Godot ni modificar el entorno
    local.
-   No hacer commits sin autorización explícita.
-   Después de la consulta, revisar el mapa y decidir si se implementa
    sobre la arquitectura actual o si hace falta una reorganización
    puntual.
-   En cada tarea de implementación acotada, devolver resumen, archivos
    modificados, pruebas relacionadas/estado, riesgos y pendientes.
-   Mantener las decisiones confirmadas separadas de las propuestas y
    las cuestiones abiertas.

------------------------------------------------------------------------

## Resumen ejecutivo

**Decidido:** creador al iniciar → jugador único en memoria →
laboratorio; cuatro perfiles con el mismo presupuesto de atributos; seis
atributos; movimiento/regate con control directo; evaluación separada
entre decisión, ejecución y resultado; feedback contextual sin notas
numéricas; construir situaciones individualmente antes de orquestarlas.

**Próximo paso:** pedir a MiMo una explicación de la arquitectura que ya
tiene en contexto y del sistema de tests, sin pedirle que recorra todo
el repositorio ni que cambie archivos. Revisar esa respuesta antes de
decidir la integración o un refactor.

**Todavía no decidido:** distribuciones numéricas, fórmulas de
evaluación, detalles de controles, criterios de selección y clubes, y
gran parte del contenido narrativo/social.
