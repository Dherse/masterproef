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
    #hexagonal_interconnect(side: 13cm, hex-side: 1.5cm, 10, 14)
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
import phos as ph

# Import the platform support package
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
= Example: lattice filter <anx_lattice_filter>


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
    input: optical,
    filter_kind: FilterKind,
) -> optical {
    // Steps:
    // 1. we compute the coefficients of the filter in the form ((Fraction, Phase)...)
    //    that is: a list of coefficients and phases
    // 2. we fold over the list of coefficients and phases, that is, we iterate over
    //    the list, and for each element, we apply a function to the current value
    //    and the element, and return the result as the new current value, turning a
    //    list of coefficients and phases into a single value, our starting value is
    //    the input signal. In the fold we:
    //   1. split the signal into two, the fraction that is split is based on the computed
    //      coefficients, one that will have the phase difference applied to it, and one
    //      that will have not the phase applied to it
    //   2. we constrain the phase difference between the two signals, imposing the computed
    //      phase difference
    //   3. we merge the two signals back into one
    filter_kind_coefficients(filter_kind)       // ((Fraction, Phase)...)
        |> fold(input, |acc, (coeff, phase)| {  // Types insides:
            acc                                     // optical
                |> split((coeff, 1 - coeff))        // (optical, optical)
                |> constrain(d_phase = phase)       // (optical, optical)
                |> merge()                          // optical
        })                                      // optical
}
```

= Example: spectrometer with fixed bins <anx_spectrometer>

```phos
// A spectrometer with fixed, compile time bins.
// Inputs:
// - input: the input optical signal
// - min: the minimum wavelength, constrained to be at most equal to the maximum wavelength
// - max: the maximum wavelength, constrained to be at least equal to the minimum wavelength
// - nbins: the number of bins, constrained to be at least 1
// 
// Output:
// - electrical: the demodulate amplitude in each bin
syn spectrometer(
    input: optical,
    @max(max)
    min: Wavelength,
    @min(min)
    max: Wavelength,
    @min(1)
    nbins: uint
) -> (electrical...) {
    // We build a list of wavelength that we will use to split the input signal
    let wavelengths: (float...) = linspace(min, max, nbins);

    // We compute the bandwidth of each bin
    let bandwidth: Bandwidth = (max - min) / tuning.len();

    // We process the signal in the following steps:
    // 1. we split the signal into `nbins` bins, each bin is a fraction of the input signal
    // 2. we zip the signal with the wavelength, so that we can keep track of the wavelength
    //    of each bin
    // 3. we filter each bin to only keep the signal that is within the bandwidth of the bin
    // 4. we detect the signal in each bin
    input                                           // optical
        |> split(splat(1.0, nbins))                 // (optical...)
        |> zip(wavelengths)                         // ((optical, Wavelength)...)
        |> map(set filter(bandwidth = bandwidth))   // (optical...)
        |> map(detector)                            // (electrical...)
}
```

= Example: improved spectrometer with fixed bins <anx_spectrometer>

```phos
// A spectrometer with fixed, compile time bins, optimized for
// lower power losses.
syn low_loss_spectrometer(
    input: optical,
    @max(max)
    min: Wavelength,
    @min(min)
    max: Wavelength,
    @min(1)
    nbins: uint
) -> (electrical...) {
    // We build a list of wavelength that we will use to split the input signal
    let wavelengths: (float...) = linspace(min, max, nbins);

    // We compute the bandwidth of each bin
    let bandwidth: Bandwidth = (max - min) / tuning.len();

    // We process the signal in the following steps:
    // 1. we iterate over each wavelength
    // 2. we pass each signal through a drop filter, that will drop the signal that is
    //    outside of the bandwidth of the bin into a drop signal
    //    Drop signals are are being used as a state in the folding operation, allowing
    //    us to keep track of the last drop signal and use it as the input of the next
    //    iteration
    // 3. we detect the signal in each bin
    // 4. we collect the detected signal and the last drop signal gets sent to a sink
    wavelengths                                                  // (Wavelength...)
        |> fold(((), input), |wavelength, (demod, drop)| {       // Types inside:
            drop                                                    // optical
                |> drop_filter(wavelength, bandwidth = bandwidth)   // (optical, optical)
                |>((demod..., detector()), _)                       // ((electrical...), optical)
        })                                                       // ((electrical...), optical)
        |> (_, sink())                                           // ((electrical...), none)
        |> get(0)                                                // (electrical...)
}
```

= Example: coherent 16-QAM transceiver <anx_coherent_transceiver>

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
    input
        |> split((1.0, 1.0, 0.5, 0.5))
        |> zip((a, c, b, d))
        |> modulate(type = Modulation::Amplitude)
        |> constrain(d_phase = 90°)
        |> merge()
}

syn coherent_receive(
    input: optical,
    ref: optical,
) -> (electrical, electrical) {
    input
        |> filter(1150 nm, 100 GHz)
        |> split((1.0, 1.0))
        |> zip(ref |> split((1.0, 1.0)))
        |> map(merge)
        |> map(demodulate)
}

syn main(
    ref: optical,
    input: optical,
    (i, ni, q, nq): (electrical, electrical, electrical, electrical),
) -> (optical, electrical, electrical) {
    let (i_out, q_out) = coherent_receive(input, ref);
    let output = coherent_transmitter(i, ni, q, nq);

    (output, i_out, q_out)
}
```