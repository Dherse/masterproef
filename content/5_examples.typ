#import "../elems/acronyms.typ": *
#import "../elems/infos.typ": *
#import "../elems/template.typ": *

= Examples of photonic circuit programming <sec_examples>

Several different application areas were mentioned in @photonic_processors_use_cases, and in this section, some of these areas will be demonstrated using the @phos programming language. The examples are meant to be mockups of real applications, and are not meant to be complete implementations, focusing solely on the @phos part of their design. These examples will be explored in different levels of details depending on the complexity of the application and how much of the capabilities of @phos they demonstrate. The full code, with comments, and type annotations is available starting at @anx_lattice_filter.

Each example will begin with a short theoretical overview containing the relevant information to understand the example. Then, portions of the @phos code will be presented and explained. Finally, simulation results will be shown to demonstrate the correctness of the implementation.

== Lattice filter

== Spectrometer

=== Fixed bins implementation

=== Improved fixed bins implementation

== Beam forming

```phos
syn beam_forming(
    input: optical,
    phase_shifts: (electrical...),
) -> (optical...) {
    input
        |> split(splat(1.0, phase_shifts.len()))
        |> zip(phase_shifts)
        |> map(set modulate(type: Modulation::Phase))
        |> constrain(d_delay = 0)
}
```

#pagebreak(weak: true)
== Coherent 16-QAM transceiver

In this next example, a simple 16-#gloss("qam", short: true) transceiver will be demonstrated along with simulation results. The code for this example is available at @anx_coherent_transceiver. This example will first cover the theoretical background needed to understand the motivation for the example and the measurements taken, followed the modulation aspects of the transceiver, and then the demodulation aspects.

=== Theoretical background

#info-box(kind: "definition", footer: [ Adapted from @ref_qam. ])[
    *QAM* refers to *quadrature amplitude modulation*, a modulation scheme where the information is encoded in both the amplitude and the phase of the signal. The *16* refers to the number of symbols in the constellation, which is the number of different values that the signal can take. In this case, the data encoded is therefore 4 bits per symbol, for a total of 16 possible values.
]

In telecommunications, and especially in high-speed communication, engineers need to be able to transmit as much information as possible in a given bandwidth, while still maintaining good immunity to noise and other impairments. One way to achieve these higher throughputs, is by using more advanced modulation schemes, the state of the art in photonic communication being 64-#gloss("qam", short: true) @ishimura_64-qam_2022. In this example however, the state of the art will not be reproduced and will instead be focused on a simpler 16-#gloss("qam", short: true) modulation scheme, based on the work by _Talkhooncheh, Arian Hashemi, et al._ @talkhooncheh_200gbs_2023.

Modulations are often visualized using two types of diagrams: so-called _eye diagrams_ which show the transitions between symbols, and _constellation diagrams_ which show the actual symbols after sampling. These two visualizations are used to measure the quality of the received signal and to visualize any impairment it might have suffered during transmission. Eye diagrams are built by overlaying many transitions between symbols over one another, slowly building a statistical representation of the signal. Constellation diagrams are built by sampling the signal at a given rate, and plotting its magnitude and phase in a complex plane. The resulting plot is a point cloud that can be used to visualize the symbols that were transmitted.

Finally, the measure that will be used to quantify the quality of the transceiver is not the @ber, as the measurement will be taken at the output of the transmitter, and therefore the bit error rate will be zero, but rather the @evm. The @evm is a measure of the difference between the ideal constellation and the actual constellation, and is defined as in @eq_evm, with $N$ the number of samples, $I_"err"$ and $Q_"err"$ the error in the in-phase and quadrature components of the constellation, $"EVM"_"%"$ the @evm in percentage, and $"EVM Normalization Factor"$ is a normalization factor that depends on the modulation scheme used, for 16-#gloss("qam", short: true), it is the maximum magnitude of the constellation @keysight_technologies_evm. A visualization of EVM can be found in @fig_evm. One this definition, one can see that the @evm is a measure of the average distance between the ideal constellation and the actual constellation and should, therefore, be minimized.

$
"EVM"_"%" = sqrt(1 / N sum_(i = 0)^(N - 1)(I_"err" [i]^2 + Q_"err" [i]^2)) / "EVM Normalization Factor" dot 100%
$ <eq_evm>

#figurex(
    title: [ Error vector magnitude -- reference plot ],
    caption: [ Error vector magnitude -- reference plot, showing the reference and measured IQ points, and the @evm vector of the sample. ],
)[
    #image(
        "../figures/drawio/evm.png",
        width: 60%,
        alt: "Shows a 2D cartesian plot with the X-axis labelled as I, the Y-axis labelled as Q, the vector of the ideal IQ point is shown, and the measure IQ point. The EVM vector is drawn between the two points."
    )
]<fig_evm>

=== Modulation

The circuit being built is shown in @fig_qam_mod, it consists of a laser source, which, in the @phos code shown in @lst_modulation, is considered to be external to the device. The light is then split into four parts, two of which are split to one quarter of the total light, while the remaining two each receive half of the total light. Each signal is then modulated, on a real chip, this could be done using an electro-absorption modulator (EAM) or a @mzi based modulator. The signals are then phase shifted to form the _I_ and the _Q_ modulation. The first two signals form the in-phase modulation, while the remaining two signals form the quadrature modulation. The four modulated signals are then combined and sent to the output.

#figurex(
    title: [ 16-#gloss("qam", short: true) modulator circuit. ],
    caption: [ 16-#gloss("qam", short: true) modulator circuit, showing the splitter, modulators, phase shifters, and interferometer. ],
)[
    #image(
        "../figures/drawio/qam_mod.png",
        width: 100%,
        alt: "Show a diagram showing a laser source being split into four parts, each part being modulated then phase shifted, finally all signals are combined together."
    )
]<fig_qam_mod>

The input signal is first split into four parts (line $#15$) into four parts with weight $1.0$, $1.0$, $0.5$, and $0.5$. These four signals are zipped (line $#16$), meaning that they are combined into a single value containing an optical and an electrical signal each. All of those values are then amplitude modulated (line $#17$). The second, third, and fourth signals are then phases shifted such that they are $0$, $90$, and $180$ degrees out of phase with the first signal (line $#18$). The four signals are then interfered together (line $#19$) and sent to the output. The resulting signal is a 16-#gloss("qam", short: true) modulated signal, composed of four binary values per symbol.

#figurex(
    title: [ Example in @phos of a 16-#gloss("qam", short: true) modulator. ],
    caption: [ Example in @phos of a 16-#gloss("qam", short: true) modulator. The four binary sources are modulated on a common laser source, and then interfered together. The full commented source can be found in @anx_coherent_transceiver. ],
)[
#raw_offset(9)
```phos
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
```
]<lst_modulation>

From this code, one can build a signal flow diagram containing all of the intrinsic operations and constraints, note that the input was replaced with a source of intensity in arbitrary unit of $1.0$, with an @awgn with mean $0.0$ and standard deviation $0.025$ added to it. The resulting signal flow diagram can be found in @fig_qam_tx_sgd. This example is trivial to simulate for the constraint-solver, with four $100 "Gb"\/"s"$ binary sources, it finishes simulating a 1ns window in $45 "ms"$ on a recent _AMD_ @cpu.

In @fig_results, one can see the simulation results, showing the input signal with its simulated noise in #link(<fig_results>)[(a)], the output signal in #link(<fig_results>)[(b)], and the intermediary signals in #link(<fig_results>)[(c)] and #link(<fig_results>)[(d)]. Finally in #link(<fig_results>)[(e)], one can see the constellation, from which the @evm can be calculated as $4.41%$, which is $-17.11 "dB"$ when expressed logarithmically. At these speeds, with a fairly high noise, this can be considered a good result as it leads to a @ber of zero.

#figurex(
    title: [ Signal flow diagram of a 16-#gloss("qam", short: true) modulator. ],
    caption: [ Signal flow diagram of a 16-#gloss("qam", short: true) modulator, showing the different components. ],
)[
    #image(
        "../figures/drawio/qam_tx_sgd.png",
        width: 70%,
        alt: "Shows a graph of the signal flow, starting at the input, then into a splitter, the four arms go respectively into, a modulator, a modulator and a phase shifter, a modulator and a phase shifter, and a modulator and a phase shifter. The four arms are then merged together and sent to the output."
    )
]<fig_qam_tx_sgd>

#figurex(
    title: [ Simulation results of a 16-#gloss("qam", short: true) modulator. ],
    caption: [ Simulation results of a 16-#gloss("qam", short: true) modulator, showing the input signal, the output signal, and the intermediary signals, along with the constellation points, and reference points. The constellation points have been normalized before being shown. ],
)[
    #image(
        "../figures/qam_constellation.png",
        width: 100%,
        alt: "Shows the input signal, as a mostly constant signal with some noise, then  shows the output signal which is a 16-QAM modulated signal, with the constellation points shown. Also shows the intermediary A, B, C, and D signals."
    )
]<fig_results>

=== Demodulation

#pagebreak(weak: true)
== Fiber sensing

```phos

syn fiber_sensor(
    input: optical,
    @len(refs.len())
    wavelengths: (Wavelength...),
    @len(wavelengths.len())
    refs: (optical...),
    measure: bool,
) -> (optical, electrical, ...) {
    let out = if measure {
        refs |> merge()
    } else {
        empty()
    };

    input
        |> split(splat(1.0, wavelengths.len()))
        |> zip(wavelengths)
        |> map(set filter(bandwidth = 1 GHz))
        |> map(demodulate)
}

```

== Switch matrix

#raw_offset(16)
```phos
syn matrix(
    inputs: (optical, ...),
    switches: (bool, ...),
) -> (optical, ...) {

}
```

== Analog matrix multiplication