#import "../elems/acronyms.typ": *
#import "../elems/infos.typ": *
#import "../elems/template.typ": *
#import "../elems/hexagonal.typ": hexagonal_interconnect

#set heading(numbering: "A", supplement: [Annex])
#counter(figure.where(kind: table)).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: raw)).update(0)

#set page(flipped: true)
= Programming paradigm poster <anx_paradigms>
#counter(figure.where(kind: table)).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: raw)).update(0)
#set figure(numbering: (x) => [A.#x])

#figurex(
    title: [ Programming paradigms poster. ],
    caption: [ Programming paradigms poster, showing the different programming paradigms and their relationships. Created by _Peter Van Roy_ @van_roy_classification_nodate. ],
)[
    #image("../figures/programming_paradigms.png", width: 71%)
]

#set page(flipped: false)
= PHÔS: a formal grammar <anx_phos_grammar>
#counter(figure.where(kind: table)).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: raw)).update(0)
#set figure(numbering: (x) => [B.#x])

#set page(flipped: true, columns: 1)
= AST data structure: overview <anx_ast_overview>
#counter(figure.where(kind: table)).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: raw)).update(0)
#set figure(numbering: (x) => [C.#x])
#figurex(
    title: [ UML diagram of parts of the @ast relevant for @sec_ast. ],
    caption: [
    UML diagram of parts of the @ast relevant for @sec_ast. It is incomplete since phos contains 120 data structures to fully represent the @ast.
    ]
)[
    #image("../figures/drawio/ex_ast.png", width: 88%)
]

#set page(flipped: true)
= Bytecode execution <anx_bytecode_execution>
#counter(figure.where(kind: table)).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: raw)).update(0)
#set figure(numbering: (x) => [D.#x])
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
#counter(figure.where(kind: table)).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: raw)).update(0)
#set figure(numbering: (x) => [E.#x])

#figurex(
    title: [ Graph representation of a mesh. ],
    caption: [
        Graph representation of a mesh, showing the direction that light is travelling in, and all of the possible connections. Based on the work of Xiangfeng Chen, et al. @chen_graph_2020. This visualisation was created with the collaboration of Léo Masson, as mentioned in #link(<sec_ack>)[the acknowledgements].
    ],
)[
    #hexagonal_interconnect(side: 13cm, hex-side: 1.5cm, 10, 14)
]<fig_graph_representation_mesh>

#set page(flipped: false)
= Marshalling library example <anx_marshalling_library_example>
#counter(figure.where(kind: table)).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: raw)).update(0)
#set figure(numbering: (x) => [F.#x])

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
import phos as ph

# Import the platform-support package
import prg_device as prg

# Create the device with the specific support package
device = ph.Device(prg.DeviceDescription())

# Try and load a module, this will compile the module
module = device.load_module("module.phos")

# Create the I/O, each `io` calls returns an input and an output
electrical   = device.electrical_input(0)
(input, _)   = device.io(0)
(_, output0) = device.io(1)
(_, output1) = device.io(2)

# Instantiate the module, first passing in the inputs and parameters
# and then the outputs. This run evaluation of the module.
instance = module(input, electrical, name="Module Instance")
                .output(output0, output1)

# Build the design, this will run synthesis, with area optimisation
built = device.synthesise(instance, optimisation="area")

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
    title: [ Layout of the circuit in the marshalling library example.],
    caption: [ Layout of the circuit in the marshalling library example, showing the path that the light takes inside of the photonic processor, as well as the state of each photonic gate. It also shows the path of the modulated light in red, and highlight the splitter. ]
)[
    #image(
        "../figures/drawio/chip_marshalling_ex.png",
        height: 90%,
        alt: "Shows a photonic chip made of a rather large hexagonal mesh, with modulators on the bottom, detectors on the top, and optical I/O on either remaining sides."
    )
] <fig_marshalling_circ>

#set page(flipped: false)

= Example: Beam forming system <anx_beam_forming>
#counter(figure.where(kind: table)).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: raw)).update(0)
#set figure(numbering: (x) => [G.#x])

#figurex(
    title: [ Example in @phos of beam-forming system. ],
    caption: [ Example in @phos of beam-forming system, parametric over the number of channels. ],
)[
```phos
// Create a simple beam-forming system
// This system takes an input optical signal and a set of electrical signals
//  1. It splits the input optical signal into N optical signals
//  2. It ensures that the phase of each of the optical signals is the same
//  3. It modulates each of the optical signals with the electrical signals
//  4. It ensures that the delay of each of the optical signals is the same
syn beam_forming(
    input: optical,
    phase_shifts: (electrical...),
) -> (optical...) {
    input                                               // optical
        |> split(splat(1.0, phase_shifts.len()))        // (optical...)
        |> constrain(d_phase = 0)                       // (optical...)
        |> zip(phase_shifts)                            // ((optical, electrical)...)
        |> map(set modulate(type: Modulation::Phase))   // (optical...)
        |> constrain(d_delay = 0)                       // (optical...)
}
```
]

= Example: coherent 16-QAM transmitter <anx_coherent_transmitter>
#counter(figure.where(kind: table)).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: raw)).update(0)
#set figure(numbering: (x) => [H.#x])

#figurex(
    title: [ Example in @phos of a 16-#gloss("qam", short: true) modulator. ],
    caption: [ Example in @phos of a 16-#gloss("qam", short: true) modulator. The four binary sources are modulated on a common laser source, and then interfered together. ],
)[
```phos
// Coherent transmitter, modulates four binary signals into a 16-QAM signal.
// 1. the signal is split into four, each signal is a fraction of the input signal
// 2. each signal is zipped with its corresponding electrical signal
// 3. each signal is modulated using amplitude modulation
// 4. the phase difference between the four signals is constrained to 90° between each
//    other
// 5. the four signals are merged back into one
// Note: the splitting ratios and order of modulation are chosen to match the modulation
//       order for the coherent transmission
syn coherent_transmitter(
    input: optical,
    (a, b, c, d): (electrical, electrical, electrical, electrical),
) -> optical {
    input                                           // optical
        |> split((1.0, 1.0, 0.5, 0.5))              // (optical, optical, optical, optical)
        |> zip((a, c, b, d))                        // ((optical, electrical), ...)
        |> modulate(type = Modulation::Amplitude)   // (optical, optical, optical, optical)
        |> constrain(d_phase = 90°)                 // (optical, optical, optical, optical)
        |> merge()                                  // optical
}
```
] <lst_modulation>
= Example: lattice filter <anx_lattice_filter>
#counter(figure.where(kind: table)).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: raw)).update(0)
#set figure(numbering: (x) => [I.#x])

#figurex(
    title: [ Example in @phos of a parametric lattice filter. ],
    caption: [ Example in @phos of a parametric lattice filter. ],
)[
```phos
// The kinds of filter that can be used.
// For this example, we only support Chebyshev and Butterworth.
enum FilterKind {
    Chebyshev(uint),
    Butterworth(uint),
}

// Computes the coefficient of a given kind of filter
fn filter_kind_coefficients(
    filter_kind: FilterKind,
) -> ((Fraction, Phase)...) {
    ...
}

// Implements the latice filter
syn lattice_filter(
    a: optical,
    b: optical,
    filter_kind: FilterKind,
) -> (optical, optical) {
    // Steps:
    // 1. we compute the coefficients of the filter in the form ((Fraction, Phase)...)
    //    that is: a list of coefficients and phases
    // 2. we fold over the list of coefficients and phases, that is, we iterate over
    //    the list, and for each element, we apply a function to the current value
    //    and the element, and return the result as the new current value, turning a
    //    list of coefficients and phases into a single value, our starting value is
    //    the a tuple of both input signals. In the fold we:
    //   1. couple the signals together with the computed coefficient
    //   2. we constrain the phase difference between the two signals, imposing the computed
    //      phase difference
    filter_kind_coefficients(filter_kind)       // ((Fraction, Phase)...)
        |> fold((a, b), |acc, (coeff, phase)| { // Fold over the list of coefficients:
            acc                                     // (optical, optical)
                |> coupler(coeff)                   // (optical, optical)
                |> constrain(d_phase = phase)       // (optical, optical)
        })                                      // (optical, optical)
}
```
]

= Example: MVM <anx_matrix_vector>
#counter(figure.where(kind: table)).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: raw)).update(0)
#set figure(numbering: (x) => [J.#x])

#figurex(
    title: [ Example in @phos of an analog matrix-vector multiplier. ],
    caption: [ Example in @phos of an analog matrix-vector multiplier. ],
)[
```phos
// A single Mach-Zehnder interferometer based gate
syn mzi_gate(
    a: optical,
    b: optical,
    (beta, theta): (Phase, Phase),
) -> (optical, optical) {
    (a, b)
        |> coupler(0.5)
        |> constrain(d_phase = beta)
        |> coupler(0.5)
        |> constrain(d_phase = theta)
}

// Produces a 4x4 matrix-vector multiplier
syn matrix_vector_multiply(
    source: optical,
    (a, b, c, d): (electrical, electrical, electrical, electrical),
    coefficients: (
        (Phase, Phase), (Phase, Phase), (Phase, Phase),
        (Phase, Phase), (Phase, Phase), (Phase, Phase)
    )
) -> (electrical, electrical, electrical, electrical) {
    let (ref_a, ref_b, ref_c, ref_d, rest...) = source |> split(splat(1.0, 8));
    let (a, b, c, d) = (a, b, c, d)
        |> zip((ref_a, ref_b, ref_c, ref_d))
        |> modulate(type_: Modulation::Amplitude)
    
    let (c1, d1) = mzi_gate(c, d, coefficients.0);
    let (b1, c2) = mzi_gate(b, c1, coefficients.1);
    let (y1, b2) = mzi_gate(a, b1, coefficients.3);
    let (c3, d2) = mzi_gate(c2, d1, coefficients.2);
    let (y2, c4) = mzi_gate(b2, c3, coefficients.4);
    let (y3, y4) = mzi_gate(c4, d2, coefficients.5);

    (y1, y2, y3, y4)
        |> zip(rest)
        |> demodulate(type_: Modulation::Coherent)
}
```
]