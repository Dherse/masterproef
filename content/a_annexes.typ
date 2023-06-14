#import "../elems/acronyms.typ": *
#import "../elems/infos.typ": *
#import "../elems/template.typ": *
#import "../elems/hexagonal.typ": hexagonal_interconnect

#set heading(numbering: "A", supplement: [Annex])
#set figure(numbering: (x) => [A.#x])
#counter(figure.where(kind: table)).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: raw)).update(0)

= PHÔS: a formal grammar <anx_phos_grammar>

#set page(flipped: true, columns: 1)
= AST data structure: overview <anx_ast_overview>
#figure(caption: [
    UML diagram of parts of the @ast relevant for @sec_ast. It is incomplete since phos contains 120 data structures to fully represent the @ast.
])[
    #image("../figures/drawio/ex_ast.png", width: 88%)
]

#set page(flipped: true)
= Bytecode execution <anx_bytecode_execution>
#figurex(
    title: [
        Execution diagram of the stack of @sec_ex_bytecode_exec.
    ],
    caption: [
        Execution diagram of the stack of @sec_ex_bytecode_exec, showing the stack before and after the execution of each of the bytecode instructions.
    ]
)[
    #image("../figures/drawio/execution.png", width: 85%)
] <fig_annex_execution>

#set page(flipped: true)
= Graph representation of a mesh <anx_bytecode_instruction_set>

#figurex(
    title: [ Graph representation of a mesh. ],
    caption: [
        Graph representation of a mesh, showing the direction that light is travelling in, and all of the possible connections. Based on the work of Xiangfeng Chen, et al. @chen_graph_2020. This visualization was created with the collaboration of Léo Masson, as mentioned in #link(<sec_ack>)[the acknowledgements].
    ],
)[
    #hexagonal_interconnect(side: 14cm, hex-side: 1.5cm, 10, 14)
]<fig_graph_representation_mesh>

#set page(flipped: false)
= Marshalling library example <anx_marshalling_library_example>

#figurex(
    title: [ @phos example used in @lst_marshalling_comp.  ],
    caption: [ @phos code performing splitting and modulation, used in @lst_marshalling_comp. ],
)[
```phos
syn main(input: optical, modulated: electrical) -> (optical, optical) {
    input |> split((0.5, 0.5))
          |> (modulator(modulated, type_: ModulationType::Amplitude), _)
}
```
] <lst_marshalling_phos>

#figurex(
    title: [ Example of the marshalling library. ],
    caption: [ Example of the marshalling library, showing the configuration of the different components of the synthesis toolchain. ],
)[
```python
# Import the marshalling library
from phos import ph

# Import the platform support package
from prg_device import prg

# Create the device with the specific support package
device = ph.Device(prg.DeviceDescription())

# Try and load a module, this will compile the module
module = device.load_module("module.phos")

# Create the I/O, each `io` calls returns an input and an output
electrical   = device.electrical(0)
(input, _)   = device.io(0)
(_, output0) = device.io(1)
(_, output1) = device.io(2)

# Instantiate the module, first passing in the inputs and parameters
# and then the outputs. This run evaluation of the module.
instance = module(input, electrical, name="Module Instance")
                .output(output0, output1)

# Build the design, this will run synthesis, with area optimization
built = device.synthesize(instance, optimization="area")

# Create the user HAL in the `./iq_modulator` directory
built.generate_hal("./iq_modulator")
# Create the firmware in the `./iq_modulator.bin` file
build.generate_firmware("./iq_modulator.bin")
```
] <lst_marshalling_comp>

#pagebreak(weak: true)
#figurex(
    title: [ Example of the marshalling library for simulation. ],
    caption: [ Example of the marshalling library for simulation, showing the simulation of a module. ],
)[
```python
# Import numpy
import numpy as np

# Import plotting library
import matplotlib.pyplot as plt

# We set the simulation parameters
dt = 1e-12
tstop = 1e-6
bitrate = 10e9
t = np.arange(0, tstop, dt)
bit_timing = 1 / bitrate

# generate a test PRBS sequence
prbs = gen_prbs(12, tstop / bit_timing, 0x17D)
prbs = np.array([1.0 if x else 0.0 for x in prbs])

# Create the simulator
simulator = device.simulator()

# Create the source with some noise
noise = simulator.noise_source(0, 0.01)
source = simulator.source(nm(1550), noise=noise)

# Simulate the module
(output0, output1) = simulator.simulate(module, t).with_input(source, prbs)

# Plot `output0` and `output1` with respect to `t`
plt.plot(t, output0)
plt.plot(t, output1)
plt.show()
```
] <lst_marshalling_sim>

#set page(flipped: true)

#figurex(
    title: [ Simulation results of the marshalling layer example.],
    caption: [ Simulation results of the marshalling layer example, showing the output of the modulator, and the output directly from the splitter. The output of the modulator is the same as the output of the splitter, but with the PRBS sequence modulated onto it. ]
)[
    #image(
        "../figures/drawio/chip_marshalling_ex.png",
        height: 95%,
        alt: ""
    )
] <fig_marshalling_circ>

#set page(flipped: false)
= Test