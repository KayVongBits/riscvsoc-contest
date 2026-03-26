
# Entity: forwarding 
- **File**: forwarding.sv

## Diagram
![Diagram](forwarding.svg "Diagram")
## Ports

| Port name            | Direction | Type                  | Description |
| -------------------- | --------- | --------------------- | ----------- |
| ex_rs1_addr_i        | input     | [`REG_ADDR_WIDTH-1:0] |             |
| ex_rs2_addr_i        | input     | [`REG_ADDR_WIDTH-1:0] |             |
| mem_wr_regs_en_i     | input     |                       |             |
| mem_wr_regs_addr_i   | input     | [`REG_ADDR_WIDTH-1:0] |             |
| wb_wr_regs_en_i      | input     |                       |             |
| wb_wr_regs_addr_i    | input     | [`REG_ADDR_WIDTH-1:0] |             |
| forwarding_rs1_sel_o | output    |                       |             |
| forwarding_rs2_sel_o | output    |                       |             |

## Processes
- rs1_dorwarding_select: (  )
  - **Type:** always_comb
- rs2_dorwarding_select: (  )
  - **Type:** always_comb
