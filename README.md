# Smart Air Fryer Datapath — Verilog

A parameterized, 4-bit datapath for a smart air fryer, developed for the EEE 248 / CNG 232 Logic Design Project 2. The design combines a four-register bank, input multiplexers, a decoder, and a Central Control Unit (CCU) to model temperature comparisons and a countdown timer.

## Architecture

- Select external data from `Sensor` or `User` using `input_sel`.
- Select external input or the registered CCU result for register writeback using `load_data`.
- Enable a selected register when both `wrt_en` and `toggle` are high.
- Read two registers independently through two 4-to-1 multiplexers.
- Execute the operation selected by `ccu_opcode`.
- Capture the CCU result in the output register on every rising clock edge.
- Expose combinational comparison flags: `L` (less than), `E` (equal), and `G` (greater than).

The data width defaults to 4 bits. Arithmetic wraps at the configured width; there is no overflow flag or reset input.

## Register addressing

Write addresses follow the decoder's one-hot mapping, while read addresses follow the multiplexers' input order.

| Register | Role in the testbench | Write address | Read address |
| --- | --- | --- | --- |
| REG0 | Current temperature | `00` | `00` |
| REG1 | Current time | `11` | `01` |
| REG2 | Target time / zero reference | `01` | `10` |
| REG3 | Target temperature | `10` | `11` |

Some inline comments in `datapath.v` use different role labels; the table above follows `decoder.v` and the testbench's actual addressing.

## CCU operations

| Opcode | Operation | Result |
| --- | --- | --- |
| `000` | No operation | Retain previous CCU result |
| `001` | Decrement | `input1 - 1` |
| `010` | Load | `input1` |
| `011` | Compare | Update `L`, `E`, `G`; retain previous result |
| `100` | Display | `input1` |
| `101` | Increment | `input1 + 2` |
| `110` | Copy | `input2` |
| `111` | Store / hold | Retain previous CCU result |

Flags default to zero outside the compare operation. Store writeback is controlled by the datapath's write controls, rather than by the CCU opcode alone.

## Files

| File | Purpose |
| --- | --- |
| `datapath.v` | Top-level datapath and component wiring |
| `datapath_tb.v` | Clock generation and air fryer simulation scenarios |
| `ccu.v` | Arithmetic, transfer, and comparison operations |
| `register_4bit.v` | Parameterized register with synchronous write enable |
| `decoder.v` | 2-to-4 write-address decoder |
| `mux2to1.v` | Parameterized 2-to-1 multiplexer |
| `mux_4to1.v` | Parameterized 4-to-1 multiplexer |
| `and_gate.v` | Three-input AND gate for write enables |
| `d_ff.v`, `d_latch.v` | Standalone sequential logic building blocks |
| `project2.mpf` | Original ModelSim project configuration |

Generated simulation libraries, waveforms, transcripts, and editor backups are excluded from version control.

## Simulation with ModelSim / Questa

### Current source status

The uploaded source preserves the original project. **`datapath.v` currently contains a duplicated module body, stray `|` characters after the sensor/user multiplexer, and an unmatched `}`. It needs repair before the following compilation commands can succeed.** The `.bak` files are local backups and are intentionally excluded from the repository.

After repairing `datapath.v`, run these commands in the ModelSim Transcript from the repository directory:

```tcl
vlib work
vlog and_gate.v ccu.v d_ff.v d_latch.v decoder.v mux2to1.v mux_4to1.v register_4bit.v datapath.v datapath_tb.v
vsim work.datapath_tb
add wave -r sim:/datapath_tb/*
run -all
```

Alternatively, open `project2.mpf` and check its source paths before compiling. The explicit commands above avoid relying on machine-specific project settings.

## Testbench scenarios

The supplied testbench drives:

1. Preheating from a sensor value of 4 toward a target of 14 in increments of 2.
2. A countdown from 5 to 0 using decrement and writeback operations.
3. A greater-than comparison with sensor value 12 and target value 3.
4. An equality comparison with both values set to 8.

The testbench reports progress using `$display`. Its loops have a 20-iteration limit, and completion messages are not assertions of correctness. Review the waveforms and flags when validating the behavior. Registers begin uninitialized until written, and the CCU's hold operations infer retained state.

## Authors

- Eray Istanbul
- Osman Caner Cakmak
