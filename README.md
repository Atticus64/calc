# Basic Calculator 

Recibe una entrada con una operacion
ya sea suma, resta, multiplicación o división
Los parametros son numeros en Hexadecimal, Binario o Decimal

Ejemplo:

```bash
# Ingresa la operación a realizar
> 24h+55d
```


## Build
```
tasm /l/zi main 
tasm /l/zi str_io 
tasm /l/zi str
```

## Assemble

```
tlink /l/v/s/m main str_io str
```
