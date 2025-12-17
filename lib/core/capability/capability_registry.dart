// ⚠️ SEMANTIC VIOLATION: Stateful Service (Not Application Orchestration)
//
// RULE VIOLATIONS (Application Layer):
// ✗ Rule: "Application can ONLY do UseCase orchestration"
//   Found: Stateful manager with registration/retrieval API
//
// ✗ Rule: "Cannot preserve session/global state"
//   Found: Mutable Map<CapabilityId, Capability> _capabilities = {}
//
// ✗ Rule: "Cannot be UI's state container"
//   Found: snapshot() method provides application state to UI
//
// ✗ Rule: "Cannot manage device selection or lifecycle"
//   Found: Manages capability registration across devices
//
// WHAT THIS ACTUALLY IS:
// - A singleton stateful service
// - A global state container
// - Not a UseCase (which is a single command)
//
// WHERE IT BELONGS:
// NOT in Application layer.
// Options:
// - lib/platform/capability_registry.dart (Platform driver/adapter)
// - lib/presentation/state/capability_registry.dart (if state management is needed there)
// - A separate presentation state management layer
//
// APPLICATION LAYER PURPOSE:
// - Each UseCase = one command intent
// - Orchestrate domain rules + infrastructure calls
// - Return result, exit immediately
// - NO state preservation between calls
//
// TODO: Move implementation out of Application layer
// TODO: Define clear ownership (Platform? Presentation state manager?)
// TODO: Update all callers to use correct dependency injection
