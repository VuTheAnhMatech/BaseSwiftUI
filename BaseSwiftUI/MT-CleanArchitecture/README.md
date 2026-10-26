# MT-CleanArchitecture

BaseSwiftUI follows `Presentation -> Domain <- Data`, with Factory/DI as the
composition root. Add only layers that carry real responsibility; do not create
empty folders to imitate a template.

```text
MT-CleanArchitecture/
├── Domain/
│   ├── Entities/
│   ├── Repositories/
│   └── UseCases/
├── Data/
│   ├── DTOs/
│   ├── DataSources/{Local,Remote}/
│   ├── Mappers/
│   ├── Repositories/
│   └── Services/
├── Presentation/
│   ├── Views/
│   ├── Containers/
│   ├── Components/
│   ├── Representables/
│   └── State/
├── Navigation/
└── DI/
```

Existing BaseSwiftUI roots remain valid:

- Domain entities: `MT-CleanArchitecture/Domain/Entities`.
- Feature Views and MVI Containers: `MT-Screens`.
- App routes, coordinators, and Factory registrations: `MT-Factory`.

## Layer ownership

- `Domain/Entities`: app and feature business models. Do not import SwiftUI,
  UIKit, persistence frameworks, networking clients, or concrete SDKs.
- `Domain/Repositories`: repository protocols required by use cases.
- `Domain/UseCases`: business operations consumed by Containers.
- `Data/DTOs`: API, cache, and persistence transport models.
- `Data/DataSources`: remote/local access such as API, disk, UserDefaults, or
  database adapters.
- `Data/Mappers`: conversion between Data models and Domain entities.
- `Data/Repositories`: implementations of Domain repository protocols.
- `Data/Services`: reusable infrastructure that does not belong to a specific
  repository.
- `Presentation`: Views, MVI Containers, UI state, UIKit bridges, and UI-only
  formatting.
- `Navigation`: feature-local routes/coordinators when not owned by
  `MT-Factory`.
- `DI`: concrete construction when not owned by an existing Factory.

Views render state and send intents. Containers depend on UseCases. Data
implementations are selected only at the Factory/DI composition boundary.
