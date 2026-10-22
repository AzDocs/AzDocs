---
name: bicep-schema-type-conversion
description: "Convert Bicep resourceInput and resourceOutput schema paths into explicit local Bicep types using Azure ARM schemas. Use when replacing resourceInput/resourceOutput, deriving types from Microsoft Azure resource schemas, resolving schema path typing issues, or applying AzDocs Bicep naming conventions."
---

# Bicep Schema Type Conversion

Replace `resourceInput<...>` or `resourceOutput<...>` with an explicit local Bicep type when the schema path is too broad, unavailable, unstable, or needs a named public contract.

## Workflow

1. Identify the exact resource type and API version from the Bicep resource declaration.
2. Open the matching ARM schema:
   `https://github.com/Azure/azure-resource-manager-schemas/blob/main/schemas/<api-version>/<provider-schema>.json`
3. Confirm the provider schema matches the resource provider. Do not infer `Microsoft.DevCenter` types from a `Microsoft.DevOpsInfrastructure` schema merely because the API versions resemble each other.
4. Follow the resource property path into `resourceDefinitions` and `definitions`.
5. Translate the concrete JSON schema into Bicep types:
   - `string` -> `string`
   - `integer` -> `int`
   - `number` -> `int` or `float`, based on the schema and existing module practice
   - `boolean` -> `bool`
   - `array` -> `<itemType>[]`
   - object properties -> a named object `type`
   - `enum` -> a string literal union
   - `oneOf` containing an ARM expression -> model the concrete value type for module parameters unless expression passthrough is explicitly required
6. Preserve schema optionality. Use `?` only when the property is optional or nullable in the effective contract; do not add it just because the schema uses `oneOf`.
7. Name the resulting type and parameter according to the repository rules below.
8. Replace the schema-derived declaration with the explicit type and keep the existing default unless the schema requires a different one.
9. Run diagnostics or compile the touched Bicep file. Check generated metadata if the public parameter contract changed.

## Array Enums

For an array whose items have an enum, define a named item type and use an array of that type:

```bicep
type CatalogItemSyncType = 'EnvironmentDefinition' | 'ImageDefinition'

param catalogItemSyncTypes CatalogItemSyncType[] = []
```

Do not use `string[]` when the schema supplies a closed enum. Do not use `resourceInput` as a substitute for an enum if the purpose is to expose a precise local contract.

## Object Types

For object schemas, define a named type rather than embedding a large anonymous object in a parameter declaration:

```bicep
type NetworkRule = {
  ipAddressOrRange: string
  action: 'Allow' | 'Deny'
}

param networkRules NetworkRule[] = []
```

Use `?` for optional object properties. Use `*` only for dictionary keys represented by `additionalProperties`.

## Discriminated Unions

When a schema uses a discriminator, look for this pattern:

1. A shared object declares the discriminator property, usually as an enum.
2. A `oneOf` contains the concrete branches.
3. Each branch adds a `const` value for the discriminator and may add branch-specific properties.

Represent that pattern with one Bicep type per branch and `@discriminator` on the union:

```bicep
type statefulAgentProfileType = {
   kind: 'Stateful'
   maxAgentLifetime: string?
   gracePeriodTimeSpan: string?
}

type statelessAgentProfileType = {
   kind: 'Stateless'
}

@discriminator('kind')
type agentProfileType = statefulAgentProfileType | statelessAgentProfileType
```

For nested discriminators, repeat the pattern. Do not flatten a discriminated union into a single object with a broad discriminator union when branch-specific properties exist; that accepts invalid combinations. For example, if only the `Automatic` branch supports `predictionPreference`, define separate `automaticResourcePredictionsProfileType` and `manualResourcePredictionsProfileType` types and discriminate their union on `kind`.

The discriminator name and literal values must match the schema exactly, including casing. A schema `allOf` is usually represented by combining the shared properties into each branch type; do not emit a separate base type unless it is reused independently.

## resourceInput and resourceOutput Rules

- `resourceInput` describes a value accepted by a resource property. Convert the target property's concrete schema type, not the whole resource type.
- `resourceOutput` describes a value returned by a resource property. Preserve read-only output shape and nullability where present.
- Resolve `$ref` definitions before writing the local type.
- For `oneOf`, distinguish a real value union from the standard ARM expression alternative. Do not expose ARM's expression implementation detail in a local type unless callers must pass expressions.
- Check nested paths carefully; a path such as `.properties.catalogSettings.catalogItemSyncTypes` may resolve to an array of enum strings even though the parent property itself is an object.
- If the local Bicep CLI lacks metadata for the API version, use the verified ARM schema and a local type alias rather than downgrading the resource API version.

## AzDocs Naming

Follow `AGENTS.md` and the path-scoped Bicep instructions:

- Parameters and variables use lowerCamelCase.
- Name parameters for what callers pass, not for the current file's implementation.
- Type aliases use PascalCase when they are public domain concepts, for example `CatalogItemSyncType`.
- Use a descriptive symbolic resource name such as `devCenterProject`, not a name-oriented symbol such as `devCenterProjectName`.
- Keep names aligned with the ARM property and the module's public purpose. Do not invent abbreviations.
- Apply Azure resource naming conventions only to Azure resource names; type aliases and parameter names are Bicep identifiers, not Azure resource names.

## Validation Checklist

- Provider and API version match the schema URL.
- Every enum value matches the schema exactly, including casing.
- Array item type is correct.
- Optional properties and nullable values are preserved.
- No `resourceInput` or `resourceOutput` remains for the converted path.
- The value assigned to the resource property accepts the new type.
- The touched file has no Bicep diagnostics.
- Public parameter descriptions still describe accepted values and defaults.
