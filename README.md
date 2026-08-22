# Housely

Housely is a calm, connected operating system for shared homes. This Flutter
repository currently uses local prototype data so the complete interface and
interaction model can be validated before Supabase is connected.

## Run

```sh
flutter pub get
flutter run
```

## Quality checks

```sh
flutter analyze
flutter test
```

## Previewing Home variations

Open **You → Developer tools → State lab**. The Home variation controls cover:

- no active Home;
- new Home admin;
- first Home after joining;
- partially and fully set-up admins;
- active and all-good members;
- rent due and overdue priorities;
- household attention;
- guest stay;
- moving out; and
- archived Home.

System-state controls can be layered onto the selected variation to inspect
loading, empty, offline, service-error, permission-loss, disabled, success,
large-text and long-content behaviour. All controls are local to the running
session.

The Home UI depends on `HomeFeatureState`, not a backend SDK. A future Supabase
repository can therefore replace the mock data source without redesigning the
screens.
