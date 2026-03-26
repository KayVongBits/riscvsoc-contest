
# Entity: mem2wb 
- **File**: mem2wb.sv

## Diagram
![Diagram](mem2wb.svg "Diagram")
## Ports

| Port name    | Direction | Type | Description |
| ------------ | --------- | ---- | ----------- |
| clk          | input     |      |             |
| rst          | input     |      |             |
| Ex2Mem_Bus_s | input     |      |             |
| Mem2Wb_Bus_s | output    |      |             |

## Processes
- unnamed: ( @(posedge clk or posedge rst) )
  - **Type:** always_ff
