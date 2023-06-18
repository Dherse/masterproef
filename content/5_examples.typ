#import "../elems/acronyms.typ": *
#import "../elems/infos.typ": *
#import "../elems/template.typ": *

= Examples of photonic circuit programming <sec_examples>

Several different application areas were mentioned in @photonic_processors_use_cases, and in this section, some of these areas will be demonstrated using the @phos programming language. The examples are meant to be mockups of real applications, and are not meant to be complete implementations, focusing solely on the @phos part of their design. These examples will be explored in different levels of details depending on the complexity of the application and how much of the capabilities of @phos they demonstrate. The full code, with comments, and type annotations is available starting at @anx_beam_forming.

== Beam forming

Optical beam forming is being used to build new solid-state LiDAR systems @xu_fully_2022. These LiDARs need precise phase matching between all of the produced optical signals, as any imprecision over the phase and delay will negatively impact the precision of the overall system. Conveniently, @phos offers an easy way to ensure that signals are phase and delay matched: the `constrain` synthesizable block. It imposes a differential constraint over a number of signals, in this case, as will be visible in @lst_beam_forming, it is used to enforce equal phase into the modulators, and equal delay when going back towards the outputs.

=== Theoretical background

Beam forming allows a system to control the directionality of a signal emitted by its antennae. It requires multiple antennae at the transmitter. The transmitter then controls the phases of the emitted signals to create constructive interference in the desired direction of interest and destructive interference in the others. This allows the transmitter to focus its signal in a specific direction. This has several advantages, it can allow a transmitter to reach longer distances at the same transmitted power, it can be used to decrease interference with other transmitters, and it can be used to increase the directional precision of a system, such as in the case of a LiDAR #cite("van_veen_beamforming_1988", "zou_analog_2017").

#figurex(
    title: [ Demonstration emission pattern of a beam forming system. ],
    caption: [ 
        Demonstration emission pattern of a beam forming system, showing the main lobe and side lobes.
    ],
)[
    #image(
        "../figures/drawio/beam_forming_emission.png",
        width: 60%,
        alt: "Shows an ellipse with long length, representing the main lobe, followed by several smaller ellipses at its sides, representing the side lobes."
    )
]<fig_beam_forming_emission>

#pagebreak(weak: true)
=== PHÔS implementation

The @phos implementation relies on several key features of the @phos language, it utilizes the `split` function which is used to split a signal based on a list of weight, these weights are provided by the `splat` function which creates a list of $n$ elements all of the same value. Those signals are then constrained to have the same phase before being phase modulated using the `modulate` function. The resulting signals are then constrained to have the same delay before being sent to the outputs. The code for this example is available at @lst_beam_forming, with the fully commented code being available in @anx_beam_forming.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Constrain*]
} `constrain` is a synthesizable block that allows the user to create constraints between signals. It can be used to impose one of two constraints, either a phase constraints, matching the phases of the different signals, or a delay constraints, matching the delays of the different signals. In this case, the phase constraint is used to ensure that all of the signals have the same phase when reaching a certain component, and the delay constraint is used to ensure that all of the signals have the same delay. Recalling @sec_constraints, these constraints are different due to the large order of magnitude difference between the frequency of light and the frequency of modulated content, a phase shift on the light will have a negligible impact on the modulated content, but a delay shift on the light will have a large impact on the modulated content.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Modulate*]
} `modulate` is a synthesizable block used to modulate an optical signal, it can perform either phase modulation or amplitude modulation. In the case of amplitude modulation, the synthesis stage may create a @mzi to perform a phase to amplitude conversion. In this example, it is sed to modulate the external phase shifts onto the optical signals.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Partial function*]
} `set` allows the creation of a partial function, where parts of the arguments have already been filled, in this case, it is used to create a partial function of `modulate` where the type of modulation is already set to phase modulation.

#{
    set text(size: 12pt, fill: rgb(30, 100, 200))
    smallcaps[*Zipping & mapping*]
} `zip` allows two lists to be zipped together, creating a list of tuples, where each tuple contains the elements of the two lists at the same index. `map` allows a function to be applied to each element of a list. In this case, `zip` is used to zip the list of phase shifts with the list of optical signals, creating a list of tuples where each tuple contains an optical signal and a phase shift. This list is then mapped to a function that sets the phase shift of the optical signal to the phase shift of the tuple.

#figurex(
    title: [ @phos implementation of a configurable optical beam forming system. ],
    caption: [ @phos implementation of a configurable optical beam forming system. A fully commented version is available in @anx_beam_forming. ],
)[
```phos
syn beam_forming(
    input: optical,
    phase_shifts: (electrical...),
) -> (optical...) {
    input
        |> split(splat(1.0, phase_shifts.len()))
        |> constrain(d_phase = 0)
        |> zip(phase_shifts)
        |> map(set modulate(type_: Modulation::Phase))
        |> constrain(d_delay = 0)
}
```
]<lst_beam_forming>

=== Results

The time-domain simulation can easily be performed using the constraint solver, yielding the results shown in @fig_beam_forming. In this simulation, only four channels were simulated, each with a time-dependent phase shift at a frequency of 1 MHz. In the first simulation #link(<fig_beam_forming>)[(a)], the phases are following @eq_phase_shift, where $k$ refers to the channel number starting at zero. And in the second simulation #link(<fig_beam_forming>)[(b)], they are following @eq_phase_shift_2. The simulation shows that the phase shifts are correctly applied to the optical signals, and that the optical signals are correctly constrained to have the same phase and delay.

$
    phi_k (t) = (k dot pi)/3 + 2 pi dot 1 "MHz" dot t
$<eq_phase_shift>

$
    phi_k (t) = sin((k dot pi)/3 + 2 pi dot 1 "MHz" dot t)
$<eq_phase_shift_2>

#figurex(
    title: [ Simulation results of the beam forming system. ],
    caption: [ Simulation results of the beam forming system, showing the time-dependent phase shifts applied to the optical signals. ],
    kind: image,
)[
    #table(
        columns: (auto, 1fr),
        stroke: none,
        align: center + horizon,
        [(a)],
        image(
            "../figures/beam_forming.png",
            width: 100%,
            alt: "Shows a graph, the X-axis is the time in µs, of which 4 µs are shown, the x axis is the phase in radians, it shows all four signals being offset by pi/3 radians wrt. each other, and the phase shift being applied to each signal."
        ),
        [(b)],
        image(
            "../figures/beam_forming_sine.png",
            width: 100%,
            alt: "Shows a graph, the X-axis is the time in µs, of which 4 µs are shown, the x axis is the phase in radians, it shows all four signals being offset by pi/3 radians wrt. each other, and the phase shift being applied to each signal."
        ),
    )
]<fig_beam_forming>

#pagebreak(weak: true)
== Coherent 16-QAM transmitter

In this next example, a simple 16-#gloss("qam", short: true) transmitter will be demonstrated along with simulation results. The code for this example is available at @anx_coherent_transmitter. This example will first cover the theoretical background needed to understand the motivation for the example and the measurements taken, followed the modulation aspects of the transmitter.

=== Theoretical background

#info-box(kind: "definition", footer: [ Adapted from @ref_qam. ])[
    *QAM* refers to *quadrature amplitude modulation*, a modulation scheme where the information is encoded in both the amplitude and the phase of the signal. The *16* refers to the number of symbols in the constellation, which is the number of different values that the signal can take. In this case, the data encoded is therefore 4 bits per symbol, for a total of 16 possible values.
]

In telecommunications, and especially in high-speed communication, engineers need to be able to transmit as much information as possible in a given bandwidth, while still maintaining good immunity to noise and other impairments. One way to achieve these higher throughputs, is by using more advanced modulation schemes, the state of the art in photonic communication being 64-#gloss("qam", short: true) @ishimura_64-qam_2022. In this example however, the state of the art will not be reproduced and will instead be focused on a simpler 16-#gloss("qam", short: true) modulation scheme, based on the work by _Talkhooncheh, Arian Hashemi, et al._ @talkhooncheh_200gbs_2023.

Modulations are often visualized using two types of diagrams: so-called _eye diagrams_ which show the transitions between symbols, and _constellation diagrams_ which show the actual symbols after sampling. These two visualizations are used to measure the quality of the received signal and to visualize any impairment it might have suffered during transmission. Eye diagrams are built by overlaying many transitions between symbols over one another, slowly building a statistical representation of the signal. Constellation diagrams are built by sampling the signal at a given rate, and plotting its magnitude and phase in a complex plane. The resulting plot is a point cloud that can be used to visualize the symbols that were transmitted.

Finally, the measure that will be used to quantify the quality of the transmitter is not the @ber, as the measurement will be taken at the output of the transmitter, and therefore the bit error rate will be zero, but rather the @evm. The @evm is a measure of the difference between the ideal constellation and the actual constellation, and is defined as in @eq_evm, with $N$ the number of samples, $I_"err"$ and $Q_"err"$ the error in the in-phase and quadrature components of the constellation, $"EVM"_"%"$ the @evm in percentage, and $"EVM Normalization Factor"$ is a normalization factor that depends on the modulation scheme used, for 16-#gloss("qam", short: true), it is the maximum magnitude of the constellation @keysight_technologies_evm. A visualization of EVM can be found in @fig_evm. One this definition, one can see that the @evm is a measure of the average distance between the ideal constellation and the actual constellation and should, therefore, be minimized.

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

=== PHÔS implementation

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

From this code, one can build a signal flow diagram containing all of the intrinsic operations and constraints, note that the input was replaced with a source of intensity in arbitrary unit of $1.0$, with an @awgn with mean $0.0$ and standard deviation $0.025$ added to it. The resulting signal flow diagram can be found in @fig_qam_tx_sgd.

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

=== Results

This example is trivial to simulate for the constraint solver, with four $100 "Gb"\/"s"$ binary sources, it finishes simulating a 1ns window in $45 "ms"$ on a recent _AMD_ @cpu. In @fig_results, one can see the simulation results, showing the input signal with its simulated noise in #link(<fig_results>)[(a)], the output signal in #link(<fig_results>)[(b)], and the intermediary signals in #link(<fig_results>)[(c)] and #link(<fig_results>)[(d)]. Finally in #link(<fig_results>)[(e)], one can see the constellation, from which the @evm can be calculated as $4.41%$, which is $-17.11 "dB"$ when expressed logarithmically. At these speeds, with a fairly high noise, this can be considered a good result as it leads to a @ber of zero.

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

== Lattice filter

Lattice filters are a type of filter that can be easily built from @mzi[s] and couplers, they allow the user to easily build a filter with the frequency response that matches their needs @ruocco_soi_2013. Specifically, lattice filters are ideal components to use as they are completely passive, allowing for very low power signal processing, of particular interest for microwave signal processing in the optical domain @guan_cmos_2014. This example will shortly discuss the theoretical background of lattice filters, then show how to build such a filter in @phos, showing how easy and expressively the language can be used to build such a filter. As the constraint solver is not yet able to solve frequency domain problems, the filter will not be simulated, instead relying on theoretical results. The general form of an @mzi based lattice filter can be seen in @fig_mzi_lattice. This example is based off of _Ruocco et al._'s and _Guan et al._'s works #cite("ruocco_soi_2013", "guan_cmos_2014").

#figurex(
    title: [ @mzi based lattice filter. ],
    caption: [ @mzi based lattice filter built of three @mzi[s] with the same path length difference. ],
)[
    #image(
        "../figures/drawio/mzi_lattice.png",
        width: 75%,
        alt: "Shows an MZI based lattice filter, built using three sections with path length difference and four couplers."
    )
]<fig_mzi_lattice>

=== Theoretical background

Lattice filters are built from two elements, couplers and sections with a length difference. Assuming that there are no reflections, one can model these elements as $2 times 2$ matrices, the first one being the coupler, and the second one being a phase shifter. The _S_ matrix of a coupler can be seen in @eq_coupler, where $tau_i$ corresponds to the coupling coefficient of the $i$-th coupler. The _S_ matrix of a phase shifter can be seen in @eq_phase_shift_dif, where $beta$ corresponds to the propagation constant of the waveguide, and $Delta L_i$ corresponds to the length difference of the $i$-th section. The _S_ matrix of a complete lattice filter can then be calculated by multiplying the _S_ matrices of the couplers and sections together, as seen in @eq_lattice_filter.

$
    S_("coupler", i) = mat(
        delim: "[",
        tau_i, -j dot sqrt(1 - tau_i^2);
        -j dot sqrt(1 - tau_i^2), tau_i
    )
$<eq_coupler>

$
    S_("delay", i) = mat(
        delim: "[",
        e^(-j dot beta Delta L_i), 0;
        0, 1
    )
$<eq_phase_shift_dif>

$
    S = S_("coupler", n+1) dot product^n_(i = 1) S_("delay", i) dot S_("coupler", i)
$<eq_lattice_filter>

#pagebreak(weak: true)
=== Building the filter

@mzi based lattice filters are very simple to build in @phos, assuming that one has a function to compute the coefficients required, which would be part of a filter synthesis toolbox, here named `filter_kind_coefficients`, then one can build a filter with the code in @lst_lattice_filter. The code first computes the coefficients, then folds them, meaning that it iterates over them while accumulating a result, in this case the result are the final output signals. For each coefficient, the accumulator signals are coupled with the computed coefficient, and then constrained to the differential phase computed. Finally, the last two signals are coupled together with the final computed coefficient. The result is a filter with the frequency response of the coefficients, which can be seen in @fig_lattice_filter, showing the theoretical results of a 4th and 8th order filter. 

#figurex(
    title: [ @mzi based lattice filter in @phos. ],
    caption: [ @mzi based lattice filter in @phos, parametrically generated for the user, fully commented example in @anx_lattice_filter. ],
)[
```phos
syn lattice_filter(a: optical, b: optical, filter_kind: FilterKind) -> (optical, optical) {
    let (coeffs, final_coupler) = filter_kind_coefficients(filter_kind)
    
    coeffs |> fold((a, b), |acc, (coeff, phase)| {
            acc |> coupler(coeff) |> constrain(d_phase = phase)
    }) |> coupler(final_coupler)                                   
}
```
]<lst_lattice_filter>

#figurex(
    title: [ Theoretical frequency response of a @mzi based lattice filter in @phos. ],
    caption: [ 
        Theoretical frequency response of a @mzi based lattice filter in @phos. Fourth order example with coefficients:
        $
            (tau_i, Delta L_i) = (0.5, 30 "µm"),
            (0.8, 30 "µm"),
            (0.5, 30 "µm"),
            (0.8, 30 "µm")
        $
        and a final coupler with a coefficient of $tau_5 = 0.04$, in waveguide with an effective refractive index of $n_"eff" = 2.4$. An addition 8th order is also shown, with the coefficients from the 4th order filter repeated twice.
     ],
)[
    #image(
        "../figures/lattice_filter.png",
        width: 100%,
        alt: "Shows the frequency response of a lattice filter, with the frequency response of the individual coefficients, and the final frequency response."
    )
]<fig_lattice_filter>

#pagebreak(weak: true)
== Analog matrix-vector multiplication

As previously mentioned in @photonic_processor, there are two major kinds of programmable @pic[s], and while this work has mostly focused itself on recirculating mesh-based photonic processors, they are capable of building the same circuits as feedforward @pic[s]. A typical use case of feedforward meshes, is #gloss("mvm", long: true), this is useful for very quickly and every efficiently perform @mvm, an operation that is very common in machine learning. This example will demonstration how such a @mvm photonic circuit is built in @phos, and how to use it to perform @mvm. The example shown in this example is based of off _Shokraneh et al._'s work @shokraneh_single_2019.

This circuit is built from individual @mzi[s], with an added phase shifter, these groupings, which can be seen in @fig_mvm_mzi, are equivalent to the photonic gates from which a photonic processor is built, see @sec_photonic_proc_comp.  For this circuit, they are configured in a triangular shape, as can be seen in @fig_mvm_mzi_full. The circuit is built from 6 gates and is capable of multiplying a vector of size $4$ with a $4 times 4$ matrix.

#figurex(
    title: [ Diagram of a single @mzi gate used when building an @mvm circuit. ],
    caption: [
        Diagram of a single @mzi gate used when building an @mvm circuit. The @mzi gate is built from two couplers, and two phase shifters, the first coupler is used to split the input signal into two, the second coupler is used to recombine the two signals, the first phase shifter is used to add a phase shift to the top signal, and the second phase shifter is used to add a phase shift to the bottom signal.
    ]
)[
    #image(
        "../figures/drawio/fig_mvm_mzi.png",
        alt: "Shows a single MZI with a tunable phase shifter on one of its arms, and a phase shifter on one of its ports",
        width: 50%,
    )
]<fig_mvm_mzi>

#figurex(
    title: [ Diagram of a the full @mzi @mvm circuit. ],
    caption: [
        Diagram of a the full @mzi @mvm circuit. With the inputs annotated $I_1$ through to $I_4$, and the output annotated $Y_0$ through to $Y_3$. The circuit is built from 6 @mzi gates, with 4 inputs, and 4 outputs.
    ]
)[
    #image(
        "../figures/drawio/fig_mvm_mzi_full.png",
        width: 100%,
        alt: "Shows a mesh of MZIs gates, assembles in a triangular shape, with 3 at the top, then 2 in the middle, and 1 at the top.",
    )
]<fig_mvm_mzi_full>

From these diagrams, it becomes clear that the matrix-vector multiplication is not trivial, assuming that the final operation being performed is $Y = bold(M) dot X$, where $Y$ and $X$ are vectors, and $bold(M)$ is a matrix, these cannot be mapped one-to-one with the values of the phase shifters on the circuit. The transformation from the matrix $bold(M)$ into the corresponding phase shifts is not the focus of this thesis, therefore, the ones from _Shokraneh et al._'s work will be used instead @shokraneh_single_2019. It is interesting to note that, by performing the matrix multiplication in the analog domain, while the circuit can be made to be extremely fast, it also introduces noise and imprecision. Therefore, while in machine-learning models that rely on low-precision arithmetic, this may not be a problem, it would have limited use in applications that depend on higher-precision arithmetic.

The code to create this circuit in @phos is rather long and is therefore available in @anx_matrix_vector. It can successfully be simulated using the constraint solver. The tests were done with the following input vectors: $X = (0, 0, 0, 0), (1, 0, 0, 0), (0, 1, 0, 0), (0, 0, 1, 0), "and" (0, 0, 0, 1)$. From these values, one can verify that the circuit is indeed performing the correct operation by comparing that the first vector produces an empty vector, and that the other vectors return the corresponding column of the matrix.