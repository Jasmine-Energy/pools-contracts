# JasmineErrors

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine Errors

Convenience interface for errors omitted by Jasmine&#39;s smart contracts





## Errors

### Disabled

```solidity
error Disabled()
```



*Emitted if function is disabled*


### InvalidInput

```solidity
error InvalidInput()
```



*Emitted if input is invalid*


### Prohibited

```solidity
error Prohibited()
```



*Emitted for unauthorized actions*


### RequiresRole

```solidity
error RequiresRole(bytes32 role)
```



*Emitted if access control check fails*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |

### UnsupportedMetadataVersion

```solidity
error UnsupportedMetadataVersion(uint8 metadataVersion)
```



*Emitted if contract does not support metadata version*

#### Parameters

| Name | Type | Description |
|---|---|---|
| metadataVersion | uint8 | undefined |

### ValidationFailed

```solidity
error ValidationFailed()
```



*Emitted if internal validation failed*



