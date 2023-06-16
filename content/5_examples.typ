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
== Coherent QAM-16 transceiver

#info-box(kind: "definition")[
    *QAM* refers to *quadrature amplitude modulation*, a modulation scheme where the information is encoded in both the amplitude and the phase of the signal. The *16* refers to the number of symbols in the constellation, which is the number of different values that the signal can take. In this case, the data encoded is therefore 4 bits per symbol, for a total of 16 possible values.
]

In this next example, a simple QAM-16 transceiver will be demonstrated along with simulations results. The code for this example is available at @anx_coherent_transceiver. This example will first cover the modulation aspects of the transceiver, and then the demodulation aspects.

=== Modulation

As was previously shown, @phos supports modulate signals using the `demodulate` built-in synthesizable block. 

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