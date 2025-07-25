# CTF_MOVEMENT_2022

This repo hosts the source code for the CTF Movement 2022 write-up

## Usage
### Aptos Development Prepartion

Please check the following materials before the start:

- [Aptos Client documents: Use CLI for Configuration](https://aptos.dev/cli-tools/aptos-cli-tool/use-aptos-cli)
- [Aptos SDK: Use Aptos SDKs | Aptos Docs](https://aptos.dev/sdks/index) 
- [Aptos API Spec: Aptos API Spec | Aptos Docs](https://aptos.dev/nodes/aptos-api-spec#/)

### Aptos Client Usage 
- Compile Module
    
    `aptos move compile`

- Publish Module

    `aptos move publish --package-dir <Package_Dir> `
    
- Interact with Module

    `aptos move run --function-id <ModuleAddress>::<Module>::<Function> --args <Type>:<Value>`
    
- Run Script

    `aptos move run-script --compiled-script-path <Path_to_Compiled_Script>`
