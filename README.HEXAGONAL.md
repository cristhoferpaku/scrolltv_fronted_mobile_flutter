# 🏛 Arquitectura Hexagonal en Flutter

Esta estructura sigue los principios de **arquitectura hexagonal** para mantener una separación clara entre dominio, aplicación, infraestructura y presentación (UI).

---

## 📂 1. application/

Contiene la lógica de aplicación (**casos de uso**) que orquesta las operaciones del dominio.

- **use_cases/** → Implementaciones de casos de uso.
  - `user_use_case_impl.dart` → Servicios específicos para operaciones de usuario.
  - `use_cases.dart` → Exporta los casos de uso.

---

## 📂 2. domain/

Define el **núcleo del dominio**, incluyendo entidades, contratos y lógica de negocio.

- **dtos/** → Objetos de transferencia de datos.
  - **request/** → Estructuras para datos de entrada (ej: `user_create_request.dart`).
  - **response/** → Estructuras para datos de salida (ej: `user_response.dart`).
  - `dtos.dart` → Exporta los DTOs.
- **entities/** → Entidades del dominio.
  - `user.dart`, `platform.dart`
- **mappers/** → Transforman datos entre capas. (conversores)
- **from-dto/** → Transforman datos de dto a entidad.
- **from-entity/** → Transforman datos de la entidad a dto o ui .
- **from-ui/** → Transforman datos de la ui a la entidad.

  - `user_model_to_create_user_request.dart`, `user_response_to_model.dart`,

- **ports/** → Contratos para la comunicación entre capas.
  - **inbound/** → Interfaces para casos de uso que entran al dominio.
    - `user_case.dart`
    - `inbound_ports.dart`
  - **outbound/** → Interfaces para dependencias externas.
    - `user_repository_port.dart`
    - `outbound_ports.dart`
  - `ports.dart`
- `domain.dart` → Punto de entrada del dominio.

---

## 📂 3. infrastructure/

Implementaciones concretas de los puertos **outbound**, dependencias externas y configuración.

- **repositories/** → Implementaciones de repositorios definidos en el dominio.
  - `user_api_repository.dart`
  - `repositories.dart` → Exporta los repositorios.
- `infrastructure.dart` → Punto de entrada de infraestructura.

---

## 📂 4. ui/

Capa de presentación (**Flutter widgets**, providers, blocs).

- **components/** → Componentes visuales siguiendo Atomic Design.

  - **atoms/** → Widgets básicos reutilizables.  
    Ej: `form_footer_buttons.dart`, `form_paragraph_info.dart`
  - **molecules/** → Combinaciones de átomos.  
    Ej: `distributed_action_cell.dart`
  - **organisms/** → Componentes complejos que agrupan moléculas y átomos.  
    Ej: `distributed_form.dart`, `dialog_distributed_form.dart`
  - **templates/** → Componentes que se reutilizan en varias pantallas .
  - **pages/** → Componentes que representan una pantalla .
  - `components.dart` → Exporta los componentes.

- **constants/** → Datos fijos y configuración para la UI.
  - **schemas/** → Validación de formularios.
  - **data/** → Datos estáticos (ej: `select_options.dart`).
  - **colors/** → Definición de colores .
  - **config/** → Configuración UI .
  - **labels/** → Textos y etiquetas.
  - `constants.dart` → Exporta los constantes.
- **providers/** → Gestión de estado (ej: Bloc, Riverpod, Provider).
- `ui.dart` → Punto de entrada de la UI.

---

## consideraciones:

1. **Separación estricta de capas**

   - La **UI** no debe acceder directamente a **infraestructura** ni a **repositorios**.  
     Toda la comunicación debe pasar por la capa de **application** usando **use cases**.
   - La **infraestructura** no debe conocer la UI.  
     Sólo implementa contratos definidos en **domain**.

2. **Comunicación unidireccional**

   - **UI → Application → Domain → Infrastructure**

3. **Independencia del framework**

   - El **dominio** y la **aplicación** no deben depender de Flutter ni de paquetes externos específicos de UI.
   - Esto permite **migrar** la UI (ej: Flutter → Web o CLI) sin modificar la lógica de negocio.

4. usar de guia el modulo (AUTH)

5. instanciar en el di

```
initAuthUseCase() {
  if (!GetIt.I.isRegistered<AuthUseCase>()) {
    instance.registerFactory<AuthUseCase>(
        () => AuthUseCaseImpl(instance<AuthRepositoryPort>()));
  }
}

initAuthRepositoryPort() {
  if (!GetIt.I.isRegistered<AuthRepositoryPort>()) {
    instance.registerFactory<AuthRepositoryPort>(() => AuthApiRepository());
  }
}
```
