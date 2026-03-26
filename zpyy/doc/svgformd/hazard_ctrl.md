
# Entity: hazard_ctrl 
- **File**: hazard_ctrl.sv

## Diagram
![Diagram](hazard_ctrl.svg "Diagram")
## Ports

| Port name     | Direction | Type                  | Description |
| ------------- | --------- | --------------------- | ----------- |
| clk           | input     |                       |             |
| rst           | input     |                       |             |
| id_rs1_addr_i | input     | [`REG_ADDR_WIDTH-1:0] |             |
| id_rs2_addr_i | input     | [`REG_ADDR_WIDTH-1:0] |             |
| ex_rd_addr_i  | input     | [`REG_ADDR_WIDTH-1:0] |             |
| ex_is_load_i  | input     |                       |             |
| ex_jump_en_i  | input     |                       |             |
| stall_pc_o    | output    |                       |             |
| stall_if2id_o | output    |                       |             |
| flush_if2id_o | output    |                       |             |
| flush_id2ex_o | output    |                       |             |

## Signals

| Name               | Type  | Description |
| ------------------ | ----- | ----------- |
| is_load_use_hazard | logic |             |
| ex_jump_en_d0      | logic |             |

## Processes
- unnamed: ( @(posedge clk or posedge rst) )
  - **Type:** always_ff
- hazard_logic: (  )
  - **Type:** always_comb
