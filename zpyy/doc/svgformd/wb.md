
# Entity: wb 
- **File**: wb.sv

## Diagram
![Diagram](wb.svg "Diagram")
## Ports

| Port name      | Direction | Type                  | Description |
| -------------- | --------- | --------------------- | ----------- |
| Mem2Wb_Bus_s   | input     |                       |             |
| ram_rd_data_i  | input     | [`DATA_WIDTH-1:0]     |             |
| regs_wr_en_o   | output    |                       |             |
| regs_wr_data_o | output    | [`DATA_WIDTH-1:0]     |             |
| regs_rd_addr_o | output    | [`REG_ADDR_WIDTH-1:0] |             |

## Signals

| Name         | Type                      | Description |
| ------------ | ------------------------- | ----------- |
| ram_data_ext | logic   [`DATA_WIDTH-1:0] |             |

## Processes
- wb_ram_ext_logic: (  )
  - **Type:** always_comb
