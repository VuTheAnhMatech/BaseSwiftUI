# DI

The App owns AppDIFactory and injects it into AppNavigationHost. Factory remains
the dependency registry and override mechanism; no View uses Container.shared.

Registration files stay separated by responsibility:

- ServiceDIFactory.swift: API transport, remote/local services, token storage, defaults.
- RepositoryDIFactory.swift: implementations of Domain repository protocols.
- UseCaseDIFactory.swift: Domain operations consumed by Containers.
- ScreenDIFactory.swift: fresh Containers with initializer injection.

The first three files extend Factory.Container directly; they do not introduce
parallel pass-through wrapper objects. AppDIFactory retains its app-owned registry
through ScreenDIFactory's resolver closure. Services/repositories use registry-local
cached scope, use cases resolve on demand, and screen creation runs on MainActor.
Existing app-wide storage managers retain their storage identity.

Pass a registry with overridden registrations to AppDIFactory(registry:) for app
composition tests. ScreenDIFactory also accepts a UseCase resolver for isolated
host tests. It returns fresh Containers without launching requests at construction.

A data feature registers Service → Repository → UseCase and adds its Container
builder in ScreenDIFactory. AppRouteFactory is the screen composition boundary.
Domain/DTO/Presentation ownership remains documented in docs/architecture.md.
