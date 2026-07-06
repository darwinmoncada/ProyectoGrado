# Manual Técnico — Sistema de Inventario TI (UTS)

Documento de respaldo técnico para la sustentación del proyecto de grado. Cada sección
está redactada para poder trasladarse casi directamente a diapositivas o al capítulo de
diseño técnico del documento final de tesis.

---

## 1. Resumen del stack tecnológico y justificación de diseño

### 1.1 Backend — Spring Boot 3.2.3 / Java 17

**Por qué Spring Boot:**

- **Robustez e inversión de control (IoC):** el contenedor de Spring gestiona el ciclo de
  vida de todos los componentes (`@Service`, `@Repository`, `@RestController`) mediante
  inyección de dependencias por constructor (`@RequiredArgsConstructor` de Lombok en
  todo el proyecto). Esto desacopla la lógica de negocio de sus dependencias concretas,
  facilitando pruebas unitarias y manteniendo cada clase enfocada en una sola
  responsabilidad.
- **Spring Data JPA:** el acceso a datos se define mediante interfaces de repositorio
  (`AssetRepository`, `AreaRepository`, etc.) que extienden `JpaRepository` y
  `JpaSpecificationExecutor`. Esto elimina la necesidad de escribir SQL repetitivo para
  operaciones CRUD, mientras que los filtros de búsqueda dinámicos y complejos (ej.
  búsqueda de activos por texto + estado + área + tipo + marca simultáneamente) se
  resuelven con el patrón `Specification` (`AssetSpecification.java`), que construye
  predicados de forma programática y type-safe en vez de concatenar strings SQL.
- **Flyway:** cada cambio de esquema de base de datos vive como un archivo de migración
  versionado (`V1__...sql` a `V6__...sql`), aplicado automáticamente al arrancar. Esto
  garantiza que el esquema de la base de datos de cualquier entorno (desarrollo, local
  del jurado, producción) sea reproducible y esté versionado junto con el código, en vez
  de depender de scripts manuales o de la memoria del desarrollador.
- **Spring Security 6 + JWT stateless:** ver sección 2.

### 1.2 Frontend — React 18 + Material-UI v5

**Por qué React + MUI:**

- **Reactividad basada en estado y componentes:** la UI se reconstruye automáticamente
  cuando cambian los datos (p. ej. al registrar un movimiento de inventario, la tabla y
  las tarjetas KPI del dashboard se actualizan solas), sin manipulación manual del DOM.
- **`@tanstack/react-query`** gestiona el *cache* y la sincronización de datos del
  servidor: invalidación automática tras mutaciones (`queryClient.invalidateQueries`),
  refetch en foco de ventana, y un `staleTime` corto (30s) para que ninguna vista muestre
  información desactualizada sin necesidad de recargar la página manualmente (F5).
- **Componentes Enterprise densos:** `@mui/x-data-grid` provee tablas con paginación de
  servidor, selección múltiple y renderizado de celdas personalizado, evitando construir
  un componente de tabla desde cero para cada vista (Activos, Usuarios, Auditoría,
  Movimientos de Inventario, Dispositivos de Red).
- **Soporte nativo de modo oscuro vía `ThemeProvider`:** MUI expone `palette.mode`
  (`'light' | 'dark'`) como una propiedad de primera clase del tema. En este proyecto,
  `App.jsx` construye el tema dinámicamente según el modo activo (`getTheme(mode)`), y
  `ThemeModeContext.jsx` persiste la preferencia del usuario en `localStorage` — todos los
  componentes (`Card`, `Chip`, `AppBar`, gráficos de Recharts con tooltips propios)
  heredan los colores correctos sin necesidad de lógica condicional manual repetida en
  cada vista.

### 1.3 Base de datos — PostgreSQL 16

**Por qué PostgreSQL:**

- Motor relacional maduro con soporte estricto de integridad referencial (llaves
  foráneas), fundamental para un sistema de inventario donde un activo, un movimiento y
  un registro de auditoría están intrínsecamente relacionados.
- Soporte nativo de `JSONB`, `Specification`/consultas dinámicas vía JPA Criteria, y
  particionamiento/índices avanzados si el volumen de datos institucional crece.
- Codificación UTF-8 estricta y verificable a nivel de servidor
  (`SHOW server_encoding`), clave para un sistema con datos íntegramente en español
  (tildes, eñes) — ver `INSTRUCCIONES_DESPLIEGUE.md` sección 4 para la lección aprendida
  sobre cómo se garantizó esto de punta a punta.
- Corre igual de bien en un contenedor Docker local que en un servicio administrado en la
  nube (Neon), lo que permitió desarrollar 100% local y sincronizar datos reales de
  producción sin cambiar una línea del backend.

---

## 2. Modelo de seguridad

### 2.1 Autenticación: JWT sin estado (stateless)

El login (`POST /api/auth/login`) valida credenciales contra `BCryptPasswordEncoder` y
emite un JWT firmado (`JwtAuthenticationFilter`), con expiración de 24 horas. Cada
petición subsecuente lleva el token en el header `Authorization: Bearer <token>`; el
filtro lo valida y reconstruye el contexto de seguridad **sin sesión de servidor**
(`SessionCreationPolicy.STATELESS` en `SecurityConfig.java`), lo que permite escalar el
backend horizontalmente sin sincronizar sesiones entre instancias.

### 2.2 Autorización: control de acceso basado en roles (RBAC) de 4 niveles

| Rol                | Nivel  | Alcance                                                                 |
|--------------------|--------|--------------------------------------------------------------------------|
| `ROLE_SUPERADMIN`  | 1      | Control total, incluida la gestión de otros administradores y la eliminación definitiva de usuarios. |
| `ROLE_ADMIN`       | 2      | Gestión operativa: activos, áreas, usuarios (excepto otros admins/superadmins), reportes. |
| `ROLE_TECNICO`     | 3      | Registrar/editar activos y movimientos de inventario; sin acceso a administración de usuarios. |
| `ROLE_USUARIO`     | 4      | Solo lectura / consulta de activos e información asignada.               |

La autorización se aplica en **dos capas independientes**, por defensa en profundidad:

1. **A nivel de filtro HTTP** (`SecurityConfig.securityFilterChain`): reglas generales
   como "todo `/api/**` requiere autenticación" o "el registro de usuarios requiere
   `ADMIN` o `SUPERADMIN`" (`.requestMatchers(HttpMethod.POST, "/api/auth/register")
   .hasAnyRole("ADMIN", "SUPERADMIN")`).
2. **A nivel de método** (`@PreAuthorize`), habilitado globalmente con
   `@EnableMethodSecurity` en `SecurityConfig`. Cada endpoint sensible del controller
   declara explícitamente qué roles puede ejecutarlo, por ejemplo:

   ```java
   // AssetController.java
   @PostMapping
   @PreAuthorize("hasAnyRole('ADMIN', 'SUPERADMIN', 'TECNICO')")
   public ResponseEntity<...> create(...) { ... }

   @DeleteMapping("/{id}")
   @PreAuthorize("hasAnyRole('ADMIN', 'SUPERADMIN')")   // un TECNICO no puede eliminar
   public ResponseEntity<...> delete(...) { ... }
   ```

   ```java
   // UserController.java
   @DeleteMapping("/users/{id}")
   @PreAuthorize("hasRole('SUPERADMIN')")   // solo el SuperAdministrador elimina usuarios
   public ResponseEntity<...> deleteUser(...) { ... }
   ```

Esta redundancia intencional (filtro + método) significa que, aunque una regla a nivel de
filtro sea demasiado permisiva o se omita por error, el `@PreAuthorize` del método sigue
protegiendo el endpoint — y viceversa.

### 2.3 Jerarquía de protección entre administradores

Además del control por rol, existen reglas de negocio explícitas para proteger cuentas
elevadas: un `ROLE_ADMIN` no puede crear, editar ni eliminar cuentas `ROLE_ADMIN` o
`ROLE_SUPERADMIN` (solo un `ROLE_SUPERADMIN` puede gestionar administradores), y ningún
usuario — sin importar su rol — puede desactivar o eliminar su propia cuenta desde la
interfaz (`UserService.deleteUser`, `UserService.toggleActive`), evitando bloqueos
accidentales del sistema.

---

## 3. Gestión de infraestructura: estrategias de eliminación segura

Un sistema de inventario TI institucional no puede darse el lujo de que "eliminar un
registro" rompa el historial de auditoría o deje huérfanas las llaves foráneas de otras
tablas. Este proyecto implementa **dos estrategias complementarias**, elegidas según la
naturaleza de cada entidad:

### 3.1 Baja lógica (*soft-delete*) — para catálogos de referencia (Áreas)

Las áreas (`Area.isActive`) nunca se eliminan físicamente de la base de datos. El
endpoint de eliminación simplemente marca la bandera como falsa:

```java
// UserController.java
@DeleteMapping("/areas/{id}")
@PreAuthorize("hasAnyRole('ADMIN', 'SUPERADMIN')")
public ResponseEntity<...> deleteArea(@PathVariable Long id) {
    Area area = areaRepository.findById(id).orElseThrow(...);
    area.setIsActive(false);
    areaRepository.save(area);
    ...
}
```

El listado que consume el frontend filtra explícitamente por áreas activas
(`AreaRepository.findByIsActiveTrueOrderByName()`), por lo que un área "eliminada" deja
de ofrecerse como opción para nuevas asignaciones, pero **todos los activos que ya la
referencian (`assets.area_id`) siguen intactos** — no hay ninguna llave foránea que
romper, porque la fila nunca desaparece. Esta estrategia se eligió para catálogos que
actúan como *referencia* de otras tablas (áreas, y de forma análoga los tipos de activo),
donde el historial de "qué activo estuvo en qué área" es información operativa que debe
preservarse indefinidamente.

### 3.2 Desvinculación + eliminación física — para identidades (Usuarios)

Los usuarios sí se eliminan físicamente de la tabla `users` (a diferencia de las áreas),
porque una cuenta de usuario puede necesitar borrarse por completo por razones de
privacidad o cumplimiento. El reto: `users.id` es referenciado como llave foránea desde
`assets` (asignación y creador), `areas` (responsable), `inventory_movements` (origen,
destino, creador) y `audit_logs`. Eliminar la fila directamente violaría esas
restricciones o, peor, borraría en cascada el historial de auditoría.

La solución, implementada en `UserService.deleteUser`, es **desvincular primero y
eliminar después**, dentro de una única transacción:

```java
@Transactional
public void deleteUser(Long id) {
    ...
    auditLogRepository.detachUser(id);          // audit_logs.user_id = null
    inventoryMovementRepository.detachFromUser(id);
    inventoryMovementRepository.detachToUser(id);
    inventoryMovementRepository.detachCreatedBy(id);
    assetRepository.detachAssignedUser(id);
    assetRepository.detachCreatedBy(id);
    areaRepository.detachResponsible(id);

    userRepository.delete(user);                // ahora sí, sin violar FKs
}
```

Cada `detachX` es una operación `UPDATE ... SET columna_fk = NULL WHERE columna_fk = :id`
(vía `@Modifying @Query` en el repositorio correspondiente). El punto clave para la
trazabilidad: **`audit_logs` guarda una copia de `username`, `fullName` y `roleName` en
el momento en que se generó cada evento**, independiente de la llave foránea al usuario.
Esto significa que, aunque la cuenta se elimine por completo, el historial de auditoría
sigue mostrando *quién* hizo *qué* — solo se pierde la posibilidad de navegar desde el log
hacia el perfil actual de esa cuenta (porque ya no existe), no la identidad de quien
actuó.

Ambas estrategias resguardan la integridad referencial del inventario institucional sin
sacrificar el historial operativo, cada una aplicada donde tiene más sentido según si la
entidad es un *catálogo de referencia* (áreas → baja lógica) o una *identidad con
implicaciones de privacidad* (usuarios → eliminación física con desvinculación previa).

---

## 4. Procedimiento de respaldo y migración de datos

El sistema incluye `respaldar_datos.bat` (raíz del proyecto) para que el personal de TI
de la institución pueda migrar el sistema completo — con todo su historial de activos,
movimientos y auditoría — de una computadora a otra sin depender de Neon ni de ninguna
conexión a internet.

### 4.1 Qué hace el script

1. Verifica que el contenedor `inventario_db` esté encendido (si no, indica que hay que
   ejecutar `iniciar_sistema.bat` primero).
2. Genera un volcado completo (esquema + datos) de la base de datos con `pg_dump`,
   nombrado con la fecha del día: `backups/backup_AAAA_MM_DD.sql`.
3. Muestra los pasos exactos para completar la migración a la computadora nueva.

Igual que el resto de los flujos de datos de este proyecto, el respaldo **no se genera
con una redirección de shell** (`pg_dump ... > archivo.sql`), sino que `pg_dump` escribe
el archivo directamente dentro del contenedor con su propio flag `-f`, y el resultado se
copia al host con `docker cp` — evitando por completo la clase de corrupción de
codificación (mojibake) documentada en `INSTRUCCIONES_DESPLIEGUE.md`, sección 4.

### 4.2 Cómo migrar a otra computadora

```
Doble clic en: respaldar_datos.bat
```

Esto genera `backups\backup_AAAA_MM_DD.sql`. Luego, en la computadora nueva:

1. Copia todo el proyecto (o descomprime el `.zip` de entrega) en la computadora nueva.
2. Copia ese archivo de respaldo a la raíz del proyecto y renómbralo como `init.sql`
   (reemplazando el que venga por defecto).
3. Asegúrate de que el volumen de Docker esté vacío en la computadora nueva — si es la
   primera vez que se instala ahí, ya lo está; si ya se había usado antes, ejecuta
   `docker compose down -v` primero.
4. Ejecuta `iniciar_sistema.bat`: Postgres detecta el volumen vacío y carga
   automáticamente el respaldo completo antes de que el resto del sistema arranque.

> ⚠️ El mecanismo de precarga de Postgres (`docker-entrypoint-initdb.d`) solo se ejecuta
> la **primera vez** que arranca un volumen vacío. Si el volumen ya tiene datos (por
> ejemplo, si ya se usó el sistema antes en esa misma máquina), reemplazar `init.sql` no
> tiene ningún efecto hasta que ese volumen se borre explícitamente con
> `docker compose down -v` — este es el mismo comportamiento nativo de la imagen oficial
> de PostgreSQL, no una particularidad de este proyecto.
